import 'dart:convert';

import 'package:flutter_doing/Models/todo_item_model.dart';
import 'package:flutter_doing/Models/todo_list_model.dart';

class TodoData {
  List<TodoList> lists;
  List<TodoItem> items;
  String? activeListId;

  TodoData({List<TodoList>? lists, List<TodoItem>? items, this.activeListId})
    : lists = lists ?? [],
      items = items ?? [];

  Map<String, dynamic> toJson() => {
    'lists': lists.map((l) => l.toJson()).toList(),
    'items': items.map((i) => i.toJson()).toList(),
    'active_list_id': activeListId,
  };

  factory TodoData.fromJson(Map<String, dynamic> json) {
    return TodoData(
      lists: (json['lists'] as List? ?? [])
          .map((e) => TodoList.fromJson(e as Map<String, dynamic>))
          .toList(),
      items: (json['items'] as List? ?? [])
          .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      activeListId: json['active_list_id'] as String?,
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory TodoData.fromJsonString(String value) {
    return TodoData.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }
}
