import 'word_model.dart';

class EntityName extends WordModel {
  EntityName(String name, String yomi): super(name, yomi, '固有名詞');

  factory EntityName.fromString(String line) {
    final components = line.split(',');
    return EntityName(
      components[0], 
      components[1]
    );
  }
}