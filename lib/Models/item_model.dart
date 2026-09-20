import 'package:flutter_doing/Helpers/parse_helper.dart';
import 'package:json_annotation/json_annotation.dart';

/// aka PROJECT
@JsonSerializable()
class Item {
  @JsonKey(name: "id")
  String id;
  @JsonKey(name: "name")
  String name;
  @JsonKey(name: "priority")
  int priority;

  Item({this.id = "", this.name = "", this.priority = 0});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: decodeHtml(json['id'] as String?),
      name: decodeHtml(json['name'] as String?),
      priority: (json['working_time'] as num?)?.toInt() ?? 0,
    );
  }
}
