import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import 'task_detail_screen.dart';

class KanbanBoardScreen extends StatefulWidget {
  @override
  _KanbanBoardScreenState createState() => _KanbanBoardScreenState();
}

class _KanbanBoardScreenState extends State<KanbanBoardScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل المهام بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    try {
      context.read<TaskProvider>().loadTasks();
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة المهام'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddTaskBottomSheet(),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await taskProvider.loadTasks();
            },
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn(
                    title: 'قيد الانتظار', 
                    status: TaskStatus.todo, 
                    color: Colors.grey[300]!,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.todo),
                  ),
                  _buildKanbanColumn(
                    title: 'جاري العمل', 
                    status: TaskStatus.inProgress, 
                    color: Colors.blue[300]!,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.inProgress),
                  ),
                  _buildKanbanColumn(
                    title: 'مكتملة', 
                    status: TaskStatus.done, 
                    color: Colors.green[300]!,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.done),
                  ),
                  _buildKanbanColumn(
                    title: 'معطلة', 
                    status: TaskStatus.blocked, 
                    color: Colors.red[300]!,
                    tasks: taskProvider.getTasksByStatus(TaskStatus.blocked),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required TaskStatus status,
    required Color color,
    required List<TaskModel> tasks,
  }) {
    return Container(
      width: 300,
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // عنوان العمود
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // قائمة المهام
          tasks.isEmpty
            ? _buildEmptyState()
            : _buildTaskList(tasks, status),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined, 
              size: 60, 
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد مهام',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, TaskStatus status) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(tasks[index], status);
      },
    );
  }

  Widget _buildTaskCard(TaskModel task, TaskStatus status) {
    return GestureDetector(
      onTap: () => _showTaskDetails(task),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
            )
          ],
        ),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.status == TaskStatus.done 
                ? TextDecoration.lineThrough 
                : null,
            ),
          ),
          subtitle: task.dueDate != null
            ? Text(
                'موعد التسليم: ${_formatDate(task.dueDate!)}',
                style: TextStyle(
                  color: task.isOverdue ? Colors.red : Colors.grey,
                ),
              )
            : null,
          trailing: _getPriorityIcon(task.priority),
        ),
      ),
    );
  }

  Icon _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icon(Icons.arrow_downward, color: Colors.green);
      case TaskPriority.medium:
        return Icon(Icons.horizontal_rule, color: Colors.orange);
      case TaskPriority.high:
        return Icon(Icons.arrow_upward, color: Colors.red);
      case TaskPriority.critical:
        return Icon(Icons.warning, color: Colors.red);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void _showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailScreen(
        onTaskSaved: (task) {
          try {
            context.read<TaskProvider>().addTask(task);
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar(e.toString());
          }
        },
      ),
    );
  }

  void _showTaskDetails(TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskDetailScreen(
        existingTask: task,
        onTaskSaved: (updatedTask) {
          try {
            context.read<TaskProvider>().updateTask(updatedTask);
            Navigator.pop(context);
          } catch (e) {
            _showErrorSnackBar(e.toString());
          }
        },
      ),
    );
  }
}