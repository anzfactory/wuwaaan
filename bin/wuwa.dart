import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'extensions/iterable_extension.dart';
import 'models/character.dart';
import 'models/location.dart';
import 'models/npc.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addOption(
      'build',
      abbr: 'b',
      help: 'Build Project for dictionary or github pages (ex. dic | pages)'
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart wuwa.dart <flags> [arguments]');
  print(argParser.usage);
}

class Assets {
  static File get charactersFile => File('assets/characters.txt');
  static File get npcsFile => File('assets/npcs.txt');
  static File get locationsFile => File('assets/locations.txt');
}

class Output {
  static File get googleDic => File('build/dictionary.txt');
  static String get pagesRootPath => 'dist';
  static String get ext => 'json';
  static String pathCharacters({String? id}) {
    if (id == null) {
      return '${Output.pagesRootPath}/characters.$ext';
    } else {
      return '${Output.pagesRootPath}/characters/$id.$ext';
    }
  }
  static String pathCharactersByAttribute({String? attribute}) {
    if (attribute == null) {
      return '${Output.pagesRootPath}/attributes.$ext';
    } else {
      return '${Output.pagesRootPath}/attributes/$attribute/characters.$ext';
    }
  }
  static String pathCharactersByWeapon({String? weapon}) {
    if (weapon == null) {
      return '${Output.pagesRootPath}/weapons.$ext';
    } else {
      return '${Output.pagesRootPath}/weapons/$weapon/characters.$ext';
    }
  }
  static String pathNPCs({String? id}) {
    if (id == null) {
      return '${Output.pagesRootPath}/npcs.$ext';
    } else {
      return '${Output.pagesRootPath}/npcs/$id.$ext';
    }
  }

  static String pathLocations({String? id}) {
    if (id == null) {
      return '${Output.pagesRootPath}/locations.$ext';
    } else {
      return '${Output.pagesRootPath}/locations/$id.$ext';
    }
  }
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    
    if (results.wasParsed('build')) {
      final type = results['build'];
      switch (type) {
        case 'dic':
          _buildGoogleDictionary();
          break;
        case 'pages':
          _buildPages();
          break;
        default:
          throw Exception('unknown build type $type');
      }
    }
    print('finish');
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  }
}

void _buildGoogleDictionary() async {
  final characterList = await Assets.charactersFile.readAsLines();
  final npcList = await Assets.npcsFile.readAsLines();
  final locationList = await Assets.locationsFile.readAsLines();
  final list = [
    ...characterList.map((line) => Character.fromString(line)),
    ...npcList.map((line) => NPC.fromString(line)),
    ...locationList.map((line) => Location.fromString(line))
  ];
  
  final outputFile = Output.googleDic;
  await outputFile.create(recursive: true);
  final sink = outputFile.openWrite();
  sink.write(list.map((element) {
    return element.toTextForGoogleDic();
  }).join('\n'));
  sink.writeln(); // Google日本語入力は最後に空行いれないと最後の単語をインポートしてくれない
  await sink.flush();
  await sink.close();
}

void _buildPages() async {
  final outputs = <String, Object>{};

  // Characters
  final list = await Assets.charactersFile.readAsLines();
  final characters = list.map((line) => Character.fromString(line)).toList()..sort((lhs, rhs) => lhs.id.compareTo(rhs.id));
  outputs.addEntries(characters.map((character) => MapEntry(Output.pathCharacters(id: character.id), character)));
  outputs[Output.pathCharacters()] = characters;
  final charactersByAttribute = characters.groupBy((character) => character.attribute);
  charactersByAttribute.forEach((key, list) { if (key.isNotEmpty) outputs[Output.pathCharactersByAttribute(attribute: key)] = list; });
  outputs[Output.pathCharactersByAttribute()] = charactersByAttribute.keys.where((key) => key.isNotEmpty).toList()..sort();
  final charactersByWeapon = characters.groupBy((character) => character.weapon);
  charactersByWeapon.forEach((key, list) { if (key.isNotEmpty) outputs[Output.pathCharactersByWeapon(weapon: key)] = list; });
  outputs[Output.pathCharactersByWeapon()] = charactersByAttribute.keys.where((key) => key.isNotEmpty).toList()..sort();

  // NPCs
  final npcLines = await Assets.npcsFile.readAsLines();
  final List<NPC> npcs = npcLines.map((line) => NPC.fromString(line)).toList()..sort((lhs, rhs) => lhs.id.compareTo(rhs.id)); 
  outputs.addEntries(npcs.map((npc) => MapEntry(Output.pathNPCs(id: npc.id), npc)));
  outputs[Output.pathNPCs()] = npcs;

  // Locations
  final locationLines = await Assets.locationsFile.readAsLines();
  final List<Location> locations = locationLines.map((line) => Location.fromString(line)).toList()..sort((lhs, rhs) => lhs.id.compareTo(rhs.id)); 
  outputs.addEntries(locations.map((location) => MapEntry(Output.pathLocations(id: location.id), location)));
  outputs[Output.pathLocations()] = locations;

  for (final key in outputs.keys) {
    final charactersFile = File(key);
    charactersFile.createSync(recursive: true);
    final sink = charactersFile.openWrite();
    sink.write(jsonEncode(outputs[key]));
    await sink.flush();
    await sink.close();
  }
}
