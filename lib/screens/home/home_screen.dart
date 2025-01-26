import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../providers/task_provider.dart';
import '../../providers/auth_provider.dart';
import '../add_task_screen.dart';
import '../../utils/snackbar_helper.dart';

/// الشاشة الرئيسية للتطبيق - تعرض قوائم المهام وملف المستخدم
class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  /// بناء قسم ملف المستخدم في أعلى الشاشة
  Widget _buildUserProfile(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // صورة المستخدم
              CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
              SizedBox(width: 12),
              // معلومات المستخدم
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      authProvider.userEmail ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // زر تسجيل الخروج
              TextButton.icon(
                onPressed: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                icon: Icon(Icons.logout),
                label: Text('تسجيل الخروج'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// بناء قائمة المهام لحالة معينة
  Widget _buildTaskList(
    BuildContext context,
    String title,
    List<Task> tasks,
    TaskStatus status,
    Color color,
  ) {
    return Expanded(
      child: DragTarget<Task>(
        onWillAccept: (task) => true,
        onAccept: (task) {
          // تحديث حالة المهمة عند السحب والإفلات
          if (task.status != status) {
            context.read<TaskProvider>().updateTaskStatus(task.id, status);
            showSuccessMessage(context, 'تم تحديث حالة المهمة');
          }
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                // عنوان القائمة وعدد المهام
                Container(
                  padding: EdgeInsets.all(8.0),
                  color: color.withOpacity(0.2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          '${tasks.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // قائمة المهام
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      // تحديد لون المهمة حسب مستوى الصعوبة
                      Color priorityColor;
                      switch (task.priority) {
                        case TaskPriority.easy:
                          priorityColor = Colors.green;
                          break;
                        case TaskPriority.medium:
                          priorityColor = Colors.orange;
                          break;
                        case TaskPriority.hard:
                          priorityColor = Colors.red;
                          break;
                      }
                      
                      // بناء بطاقة المهمة القابلة للسحب
                      return Draggable<Task>(
                        data: task,
                        // شكل المهمة أثناء السحب
                        feedback: Material(
                          elevation: 4.0,
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(task.title),
                          ),
                        ),
                        // شكل المهمة في مكانها الأصلي أثناء السحب
                        childWhenDragging: Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          ),
                          child: Text(task.title, style: TextStyle(color: Colors.grey)),
                        ),
                        // شكل المهمة الطبيعي
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8.0),
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: priorityColor.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: priorityColor,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      // علامة مستوى الصعوبة
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: priorityColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: priorityColor.withOpacity(0.5),
                                          ),
                                        ),
                                        child: Text(
                                          task.priority == TaskPriority.easy
                                              ? 'سهلة'
                                              : task.priority == TaskPriority.medium
                                                  ? 'متوسطة'
                                                  : 'صعبة',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: priorityColor,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // قائمة خيارات المهمة (تعديل/حذف)
                                      PopupMenuButton(
                                        icon: Icon(Icons.more_vert, color: priorityColor),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit, color: Colors.blue),
                                                SizedBox(width: 8),
                                                Text('تعديل'),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('حذف'),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (value) {
                                          if (value == 'edit') {
                                            Navigator.pushNamed(
                                              context,
                                              AddTaskScreen.routeName,
                                              arguments: task,
                                            );
                                          } else if (value == 'delete') {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: Text('تأكيد الحذف'),
                                                content: Text('هل أنت متأكد من حذف هذه المهمة؟'),
                                                actions: [
                                                  TextButton(
                                                    child: Text('إلغاء'),
                                                    onPressed: () => Navigator.of(ctx).pop(),
                                                  ),
                                                  TextButton(
                                                    child: Text('حذف', style: TextStyle(color: Colors.red)),
                                                    onPressed: () {
                                                      context.read<TaskProvider>().deleteTask(task.id);
                                                      Navigator.of(ctx).pop();
                                                      showSuccessMessage(context, 'تم حذف المهمة بنجاح');
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              // وصف المهمة
                              Text(
                                task.description,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المهام'),
        actions: [
          // زر التقارير
          IconButton(
            icon: Icon(Icons.assessment),
            tooltip: 'التقارير',
            onPressed: () {
              Navigator.pushNamed(context, '/reports');
            },
          ),
          // زر إضافة مهمة جديدة
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AddTaskScreen.routeName);
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          return Column(
            children: [
              // قسم ملف المستخدم
              _buildUserProfile(context),
              // قوائم المهام
              Expanded(
                child: Row(
                  children: [
                    _buildTaskList(
                      context,
                      'في الانتظار',
                      taskProvider.pendingTasks,
                      TaskStatus.pending,
                      Colors.orange,
                    ),
                    _buildTaskList(
                      context,
                      'قيد المعالجة',
                      taskProvider.inProgressTasks,
                      TaskStatus.inProgress,
                      Colors.blue,
                    ),
                    _buildTaskList(
                      context,
                      'تم التنفيذ',
                      taskProvider.completedTasks,
                      TaskStatus.completed,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}