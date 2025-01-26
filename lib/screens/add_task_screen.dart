import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/snackbar_helper.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// شاشة إضافة وتعديل المهام
class AddTaskScreen extends StatefulWidget {
  static const routeName = '/add-task';

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Task? _editingTask;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  
  // إعداد منبه الإشعارات
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // تهيئة الإشعارات
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final task = ModalRoute.of(context)?.settings.arguments as Task?;
    if (task != null && _editingTask == null) {
      _editingTask = task;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedPriority = task.priority;
      _selectedDate = task.dueDate;
      _selectedTime = task.dueDate != null
          ? TimeOfDay.fromDateTime(task.dueDate!)
          : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// عرض منتقي التاريخ
  Future<void> _selectDate() async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime?.hour ?? 0,
          _selectedTime?.minute ?? 0,
        );
      });
      if (_selectedTime == null) {
        _selectTime();
      }
    }
  }

  /// عرض منتقي الوقت
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        if (_selectedDate != null) {
          _selectedDate = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            picked.hour,
            picked.minute,
          );
        }
      });
    }
  }

  /// جدولة إشعار للمهمة
  Future<void> _scheduleNotification(String title, String description, DateTime dateTime) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_reminders',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'تذكير: $title',
      description,
      tz.TZDateTime.from(dateTime, tz.local),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.easy:
        return 'سهلة';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.hard:
        return 'صعبة';
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.easy:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.hard:
        return Colors.red;
    }
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      final taskProvider = context.read<TaskProvider>();
      
      if (_editingTask != null) {
        taskProvider.updateTask(
          _editingTask!.id,
          _titleController.text,
          _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate,
        );
        showSuccessMessage(context, 'تم تحديث المهمة بنجاح');
      } else {
        taskProvider.addTask(
          _titleController.text,
          _descriptionController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate,
        );
        showSuccessMessage(context, 'تم إضافة المهمة بنجاح');
      }

      // جدولة إشعار إذا تم تحديد تاريخ ووقت
      if (_selectedDate != null) {
        await _scheduleNotification(
          _titleController.text,
          _descriptionController.text,
          _selectedDate!,
        );
      }
      
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editingTask != null ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان المهمة',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'وصف المهمة',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال وصف المهمة';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              // حقل تاريخ ووقت الإنجاز
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'تاريخ ووقت الإنجاز',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                            : 'اختر التاريخ',
                      ),
                      if (_selectedTime != null)
                        Text(
                          '${_selectedTime!.format(context)}',
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'مستوى المهمة',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: TaskPriority.values.map((priority) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedPriority == priority
                              ? _getPriorityColor(priority)
                              : _getPriorityColor(priority).withOpacity(0.2),
                          foregroundColor: _selectedPriority == priority
                              ? Colors.white
                              : _getPriorityColor(priority),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Text(_getPriorityLabel(priority)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _saveTask,
                child: Text(_editingTask != null ? 'تحديث' : 'إضافة'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}