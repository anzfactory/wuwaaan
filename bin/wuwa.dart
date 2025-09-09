import 'package:args/args.dart';

import 'builder.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addOption('build',
        abbr: 'b',
        help: 'Build Project for dictionary or github pages (ex. dic | pages)',
        allowed: ['dic', 'pages']);
}

void printUsage(ArgParser argParser) {
  print('Usage: dart run bin/wuwa.dart <flags> [arguments]');
  print(argParser.usage);
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    if (results.wasParsed('build')) {
      final type = results['build'];
      final builder = Builder();
      switch (type) {
        case 'dic':
          await builder.buildGoogleDictionary();
          break;
        case 'pages':
          await builder.buildPages();
          break;
        default:
          // This case is now unreachable due to `allowed` in ArgParser
          printUsage(argParser);
      }
    } else {
      printUsage(argParser);
    }
    print('finish');
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  } catch (e) {
    print('An unexpected error occurred: $e');
  }
}
