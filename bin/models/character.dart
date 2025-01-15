import 'package:json_annotation/json_annotation.dart';

import 'model.dart';
part 'character.g.dart';

@JsonSerializable()
class Character extends Model {
  final String id;
  final String name;
  final String yomi;
  final int rarity;
  final String attribute;
  final String weapon;
  final String version;
  
  Character(
    this.id, 
    this.name, 
    this.yomi, 
    this.rarity, 
    this.attribute, 
    this.weapon, 
    this.version
  );
  
  factory Character.fromString(String line) {
    final components = line.split(',');
    return Character(
      components[0], 
      components[1], 
      components[2],
      int.parse(components[3]), 
      components[4], 
      components[5], 
      components[6]
    );
  }

  factory Character.fromJson(Map<String, dynamic> json) => _$CharacterFromJson(json);

  
  Map<String, dynamic> toJson() => _$CharacterToJson(this);
  
  @override
  String toTextForGoogleDic() {
    return '$yomi\t$name\t人名';
  }
}
