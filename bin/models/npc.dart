import 'package:json_annotation/json_annotation.dart';

import 'model.dart';
part 'npc.g.dart';

@JsonSerializable()
class NPC extends Model {
  final String id;
  final String name;
  final String yomi;

  NPC(this.id, this.name, this.yomi);

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
  @override
  String toTextForGoogleDic() {
    return '$yomi\t$name\t人名';
  }
}