import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel? existingTask;
  final Function(TaskModel) onTaskSaved;

  const TaskDetailScreen({
    Key? key, 
    this.existingTask, 
    required this.onTaskSaved,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TaskStatus _status;
  late TaskPriority _priority;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description ?? '',
    );
    _status = widget.existingTask?.status ?? TaskStatus.todo;
    _priority = widget.existingTask?.priority ?? TaskPriority.low;
    _dueDate = widget.existingTask?.dueDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 20,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existingTask == null ? 'إنشاء مهمة جديدة' : 'تعديل المهمة',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: AppTheme.textFieldDecoration('عنوان المهمة'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: AppTheme.textFieldDecoration('وصف المهمة'),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<TaskStatus>(
              value: _status,
              decoration: AppTheme.textFieldDecoration('حالة المهمة'),
              items: TaskStatus.values
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusText(status)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<TaskPriority>(
              value: _priority,
              decoration: AppTheme.textFieldDecoration('الأولوية'),
              items: TaskPriority.values
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(_getPriorityText(priority)),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _priority = value);
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectDueDate,
              style: AppTheme.primaryButtonStyle,
              child: Text(_dueDate == null
                  ? 'اختيار موعد التسليم'
                  : 'موعد التسليم: ${_formatDate(_dueDate!)}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              style: AppTheme.primaryButtonStyle,
              child: Text('حفظ المهمة'),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() => _dueDate = pickedDate);
    }
  }

  void _saveTask() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء إدخال عنوان المهمة')),
      );
      return;
    }

    final task = TaskModel(
      id: widget.existingTask?.id,
      title: _titleController.text,
      description: _descriptionController.text,
      status: _status,
      priority: _priority,
      createdAt: widget.existingTask?.createdAt ?? DateTime.now(),
      dueDate: _dueDate,
    );

    widget.onTaskSaved(task);
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'قيد الانتظار';
      case TaskStatus.inProgress:
        return 'جاري العمل';
      case TaskStatus.done:
        return 'مكتملة';
      case TaskStatus.blocked:
        return 'معطلة';
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'منخفضة';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.critical:
        return 'حرجة';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}