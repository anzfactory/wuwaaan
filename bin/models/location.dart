import 'package:json_annotation/json_annotation.dart';

import 'word_model.dart';
part 'location.g.dart';

@JsonSerializable()
class Location extends WordModel {
  final String id;
  Location(this.id, String name, String yomi): super(name, yomi, '地名');

  factory Location.fromString(String line) {
    final components = line.split(',');
    return Location(
      components[0], 
      components[1], 
      components[2]
    );
  }

  factory Location.fromJson(Map<String, dynamic> json) => _$LocationFromJson(json);
  Map<String, dynamic> toJson() => _$LocationToJson(this);
}