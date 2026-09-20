import 'package:flutter_doing/Extensions/todo_priority_extension.dart';
import 'package:flutter_doing/Extensions/todo_status_extension.dart';

/// A single to-do entry, belonging to exactly one TodoList
class TodoItem {
  String id;
  String listId;
  String title;
  String notes;
  TodoPriority priority;
  TodoStatus status;
  DateTime createdAt;
  DateTime? completedAt;

  TodoItem({
    required this.id,
    required this.listId,
    required this.title,
    this.notes = '',
    this.priority = TodoPriority.medium,
    this.status = TodoStatus.open,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isDone => status == TodoStatus.done;
  bool get isOpen => status == TodoStatus.open;
  bool get isDeferred => status == TodoStatus.deferred;

  Map<String, dynamic> toJson() => {
    'id': id,
    'list_id': listId,
    'title': title,
    'notes': notes,
    'priority': priority.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
  };

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    final TodoStatus status;
    if (json['status'] != null) {
      status = TodoStatusX.fromName(json['status'] as String?);
    } else {
      status = (json['is_done'] as bool? ?? false)
          ? TodoStatus.done
          : TodoStatus.open;
    }

    return TodoItem(
      id: json['id'] as String? ?? '',
      listId: json['list_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      priority: TodoPriorityX.fromName(json['priority'] as String?),
      status: status,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
    );
  }
}
