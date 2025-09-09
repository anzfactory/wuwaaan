import 'dart:convert';
import 'dart:io';

import 'extensions/iterable_extension.dart';
import 'models/character.dart';
import 'models/entity_name.dart';
import 'models/location.dart';
import 'models/npc.dart';
import 'models/word_model.dart';

class Assets {
  static File get charactersFile => File('assets/characters.txt');
  static File get npcsFile => File('assets/npcs.txt');
  static File get locationsFile => File('assets/locations.txt');
  static File get entityNamesFile => File('assets/entity_names.txt');
}

class Output {
  static File get googleDic => File('build/dictionary.txt');
  static const String pagesRootPath = 'dist';
  static const String ext = 'json';

  static String characters({String? id}) =>
      _buildPath(root: pagesRootPath, dir: 'characters', ext: ext, id: id);

  static String charactersByAttribute({String? attribute}) =>
      _buildPath(root: pagesRootPath, dir: 'attributes', ext: ext, subPath: attribute, fileName: 'characters');

  static String charactersByWeapon({String? weapon}) =>
      _buildPath(root: pagesRootPath, dir: 'weapons', ext: ext, subPath: weapon, fileName: 'characters');

  static String npcs({String? id}) =>
      _buildPath(root: pagesRootPath, dir: 'npcs', ext: ext, id: id);

  static String locations({String? id}) =>
      _buildPath(root: pagesRootPath, dir: 'locations', ext: ext, id: id);

  static String _buildPath({
    required String root,
    required String dir,
    required String ext,
    String? id,
    String? subPath,
    String? fileName,
  }) {
    if (id != null) {
      return '$root/$dir/$id.$ext';
    }
    if (subPath != null) {
      final f = fileName ?? dir;
      return '$root/$dir/$subPath/$f.$ext';
    }
    if (fileName != null) {
      return '$root/$dir/$fileName.$ext';
    }
    return '$root/$dir.$ext';
  }
}

/// A builder class to handle dictionary and pages generation.
class Builder {
  /// Reads lines from an asset file, throwing a specific error if it doesn't exist.
  Future<List<String>> _readAssetLines(File file) async {
    if (!await file.exists()) {
      throw FileSystemException('Asset file not found.', file.path);
    }
    return file.readAsLines();
  }

  /// Builds the dictionary file for Google Japanese Input.
  Future<void> buildGoogleDictionary() async {
    final characterLines = await _readAssetLines(Assets.charactersFile);
    final npcLines = await _readAssetLines(Assets.npcsFile);
    final locationLines = await _readAssetLines(Assets.locationsFile);
    final entityNameLines = await _readAssetLines(Assets.entityNamesFile);

    final allWords = [
      ...characterLines.map((line) => Character.fromString(line)),
      ...npcLines.map((line) => NPC.fromString(line)),
      ...locationLines.map((line) => Location.fromString(line)),
      ...entityNameLines.map((line) => EntityName.fromString(line)),
    ];

    await _writeDictionaryFile(allWords);
    print('Successfully built Google Dictionary file at ${Output.googleDic.path}');
  }

  Future<void> _writeDictionaryFile(Iterable<WordModel> words) async {
    final outputFile = Output.googleDic;
    await outputFile.create(recursive: true);
    final sink = outputFile.openWrite();
    sink.write(words.map((word) => word.toTextForGoogleDic()).join('\n'));
    sink.writeln(); // Needed for Google Japanese Input to import the last word.
    await sink.flush();
    await sink.close();
  }

  /// Builds the JSON files for the static pages.
  Future<void> buildPages() async {
    final outputs = <String, Object>{};
    outputs.addAll(await _buildCharactersJson());
    outputs.addAll(await _buildNPCsJson());
    outputs.addAll(await _buildLocationsJson());

    await _writeJsonFiles(outputs);
    print('Successfully built JSON files in the ${Output.pagesRootPath} directory.');
  }

  Future<void> _writeJsonFiles(Map<String, Object> outputs) async {
    for (final entry in outputs.entries) {
      final file = File(entry.key);
      await file.create(recursive: true);
      file.writeAsStringSync(jsonEncode(entry.value));
    }
  }

  /// Generic method to build JSON data for models that have an `id`.
  Future<Map<String, Object>> _buildJsonData<T extends WordModel>({
    required File assetFile,
    required T Function(String) fromString,
    required String Function({String? id}) pathBuilder,
  }) async {
    final outputs = <String, Object>{};
    final lines = await _readAssetLines(assetFile);
    // Use `dynamic` to access `id` since it's not in the base WordModel.
    final items = lines.map(fromString).toList()
      ..sort((a, b) => (a as dynamic).id.compareTo((b as dynamic).id));

    outputs[pathBuilder()] = items;
    for (final item in items) {
      outputs[pathBuilder(id: (item as dynamic).id)] = item;
    }
    return outputs;
  }

  Future<Map<String, Object>> _buildCharactersJson() async {
    final outputs = <String, Object>{};
    final lines = await _readAssetLines(Assets.charactersFile);
    final characters = lines
        .map((line) => Character.fromString(line))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    outputs[Output.characters()] = characters;
    for (final character in characters) {
      outputs[Output.characters(id: character.id)] = character;
    }

    final charactersByAttribute = characters.groupBy((c) => c.attribute);
    outputs[Output.charactersByAttribute()] = charactersByAttribute.keys
        .where((key) => key.isNotEmpty)
        .toList()
      ..sort();
    charactersByAttribute.forEach((key, list) {
      if (key.isNotEmpty) {
        outputs[Output.charactersByAttribute(attribute: key)] = list;
      }
    });

    final charactersByWeapon = characters.groupBy((c) => c.weapon);
    outputs[Output.charactersByWeapon()] = charactersByWeapon.keys
        .where((key) => key.isNotEmpty)
        .toList()
      ..sort();
    charactersByWeapon.forEach((key, list) {
      if (key.isNotEmpty) {
        outputs[Output.charactersByWeapon(weapon: key)] = list;
      }
    });

    return outputs;
  }

  Future<Map<String, Object>> _buildNPCsJson() {
    return _buildJsonData<NPC>(
      assetFile: Assets.npcsFile,
      fromString: NPC.fromString,
      pathBuilder: Output.npcs,
    );
  }

  Future<Map<String, Object>> _buildLocationsJson() {
    return _buildJsonData<Location>(
      assetFile: Assets.locationsFile,
      fromString: Location.fromString,
      pathBuilder: Output.locations,
    );
  }
}