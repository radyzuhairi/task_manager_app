import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../utils/id_generator.dart';

/// مزود إدارة المهام - يتعامل مع تخزين واسترجاع وإدارة المهام
class TaskProvider with ChangeNotifier {
  // قائمة المهام المخزنة في الذاكرة
  List<Task> _tasks = [];
  
  // كائن SharedPreferences للتخزين المحلي
  SharedPreferences? _prefs;
  
  // المفتاح المستخدم لتخزين المهام في SharedPreferences
  static const String _tasksKey = 'tasks';

  // الحصول على نسخة من قائمة المهام
  List<Task> get tasks => [..._tasks];
  
  // الحصول على المهام حسب حالتها
  List<Task> get pendingTasks => _tasks.where((task) => task.status == TaskStatus.pending).toList();
  List<Task> get inProgressTasks => _tasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.status == TaskStatus.completed).toList();

  /// الحصول على مهمة حسب المعرف
  Task? getTask(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// تحميل المهام من التخزين المحلي
  Future<void> loadTasks() async {
    _prefs = await SharedPreferences.getInstance();
    final tasksJson = _prefs!.getString(_tasksKey);
    if (tasksJson != null) {
      final tasksList = json.decode(tasksJson) as List;
      _tasks = tasksList.map((item) => Task.fromJson(item)).toList();
      notifyListeners();
    }
  }

  /// حفظ المهام في التخزين المحلي
  Future<void> saveTasks() async {
    final tasksList = _tasks.map((task) => task.toJson()).toList();
    await _prefs!.setString(_tasksKey, json.encode(tasksList));
  }

  /// إضافة مهمة جديدة
  Future<void> addTask(
    String title,
    String description, {
    TaskPriority priority = TaskPriority.medium,
    DateTime? dueDate,
  }) async {
    await _initPrefs();
    final task = Task(
      id: generateId(),
      title: title,
      description: description,
      status: TaskStatus.pending,
      priority: priority,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    await saveTasks();
    notifyListeners();
  }

  /// تحديث مهمة موجودة
  Future<void> updateTask(
    String id,
    String title,
    String description, {
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    await _initPrefs();
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        updatedAt: DateTime.now(),
      );
      await saveTasks();
      notifyListeners();
    }
  }

  /// تحديث حالة المهمة
  Future<void> updateTaskStatus(String id, TaskStatus status) async {
    await _initPrefs();
    final taskIndex = _tasks.indexWhere((task) => task.id == id);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      await saveTasks();
      notifyListeners();
    }
  }

  /// حذف مهمة
  Future<void> deleteTask(String id) async {
    await _initPrefs();
    _tasks.removeWhere((task) => task.id == id);
    await saveTasks();
    notifyListeners();
  }

  /// تهيئة SharedPreferences
  Future<void> _initPrefs() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      await loadTasks();
    }
  }
}