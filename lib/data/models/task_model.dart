import 'package:cloud_firestore/cloud_firestore.dart';

enum TaskPriority {
  critical,
  high,
  growth;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.name == value,
      orElse: () => TaskPriority.growth,
    );
  }
}

class TaskModel {
  final String? id;
  final String ownerId;
  final String title;
  final String description;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final int pomodorosCompleted;

  const TaskModel({
    this.id,
    required this.ownerId,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.growth,
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.pomodorosCompleted = 0,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json, String id) {
    return TaskModel(
      id: id,
      ownerId: json['ownerId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: TaskPriority.fromString(json['priority'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as Timestamp).toDate()
          : null,
      pomodorosCompleted: json['pomodorosCompleted'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'pomodorosCompleted': pomodorosCompleted,
    };
  }

  TaskModel copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    int? pomodorosCompleted,
  }) {
    return TaskModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      pomodorosCompleted: pomodorosCompleted ?? this.pomodorosCompleted,
    );
  }
}