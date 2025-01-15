// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Character _$CharacterFromJson(Map<String, dynamic> json) => Character(
      json['id'] as String,
      json['name'] as String,
      json['yomi'] as String,
      (json['rarity'] as num).toInt(),
      json['attribute'] as String,
      json['weapon'] as String,
      json['version'] as String,
    );

Map<String, dynamic> _$CharacterToJson(Character instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'yomi': instance.yomi,
      'rarity': instance.rarity,
      'attribute': instance.attribute,
      'weapon': instance.weapon,
      'version': instance.version,
    };
