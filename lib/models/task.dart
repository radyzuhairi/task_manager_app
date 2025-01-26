import 'package:flutter/foundation.dart';

/// حالات المهمة المختلفة
enum TaskStatus {
  pending,    // في الانتظار
  inProgress, // قيد المعالجة
  completed   // تم الإنجاز
}

/// مستويات صعوبة المهمة
enum TaskPriority {
  easy,   // سهلة
  medium, // متوسطة
  hard    // صعبة
}

/// نموذج المهمة - يمثل هيكل بيانات المهمة الواحدة
class Task {
  /// معرف المهمة - فريد لكل مهمة
  final String id;
  
  /// عنوان المهمة
  final String title;
  
  /// وصف المهمة
  final String description;
  
  /// حالة المهمة (في الانتظار، قيد المعالجة، تم الإنجاز)
  final TaskStatus status;
  
  /// مستوى صعوبة المهمة (سهلة، متوسطة، صعبة)
  final TaskPriority priority;
  
  /// تاريخ ووقت الإنجاز
  final DateTime? dueDate;
  
  /// تاريخ إنشاء المهمة
  final DateTime createdAt;
  
  /// تاريخ آخر تحديث للمهمة
  final DateTime? updatedAt;

  /// منشئ المهمة
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.dueDate,
    this.updatedAt,
  });

  /// إنشاء نسخة جديدة من المهمة مع تحديث بعض الخصائص
  Task copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// تحويل المهمة إلى تنسيق JSON للتخزين
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString().split('.').last,
      'priority': priority.toString().split('.').last,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// إنشاء مهمة من بيانات JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.toString().split('.').last == (json['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}