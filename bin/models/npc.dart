import 'package:json_annotation/json_annotation.dart';

import 'word_model.dart';
part 'npc.g.dart';

@JsonSerializable()
class NPC extends WordModel {
  final String id;
  NPC(this.id, String name, String yomi): super(name, yomi, '人名');

  factory NPC.fromString(String line) {
    final components = line.split(',');
    return NPC(
      components[0], 
      components[1], 
      components[2]
    );
  }

  factory NPC.fromJson(Map<String, dynamic> json) => _$NPCFromJson(json);
  Map<String, dynamic> toJson() => _$NPCToJson(this);
}