import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

/// شاشة التقارير - تعرض إحصائيات وتوزيع المهام
class ReportsScreen extends StatelessWidget {
  static const routeName = '/reports';

  /// بناء بطاقة إحصائية لحالة معينة من المهام
  Widget _buildStatusCard(String title, int count, Color color, String subtitle) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // عرض العدد في دائرة ملونة
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    count.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قسم توزيع مستويات المهام
  Widget _buildPriorityDistribution(List<Task> tasks) {
    // حساب عدد المهام لكل مستوى
    final easyTasks = tasks.where((t) => t.priority == TaskPriority.easy).length;
    final mediumTasks = tasks.where((t) => t.priority == TaskPriority.medium).length;
    final hardTasks = tasks.where((t) => t.priority == TaskPriority.hard).length;
    final total = tasks.length;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'توزيع مستويات المهام',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (total > 0) ...[
              _buildPriorityBar('سهلة', easyTasks, total, Colors.green),
              SizedBox(height: 8),
              _buildPriorityBar('متوسطة', mediumTasks, total, Colors.orange),
              SizedBox(height: 8),
              _buildPriorityBar('صعبة', hardTasks, total, Colors.red),
            ] else
              Text('لا توجد مهام'),
          ],
        ),
      ),
    );
  }

  /// بناء شريط تقدم لمستوى معين من المهام
  Widget _buildPriorityBar(String label, int count, int total, Color color) {
    // حساب النسبة المئوية
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${count.toString()} (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        SizedBox(height: 4),
        // شريط التقدم يعرض النسبة المئوية
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقارير المهام'),
      ),
      // استخدام Consumer للاستماع لتغييرات مزود المهام
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          // الحصول على المهام حسب حالتها
          final pendingTasks = taskProvider.pendingTasks;
          final inProgressTasks = taskProvider.inProgressTasks;
          final completedTasks = taskProvider.completedTasks;
          final allTasks = taskProvider.tasks;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقات الإحصائيات
                _buildStatusCard(
                  'المهام المنجزة',
                  completedTasks.length,
                  Colors.green,
                  'عدد المهام التي تم إنجازها بنجاح',
                ),
                SizedBox(height: 16),
                _buildStatusCard(
                  'المهام قيد المعالجة',
                  inProgressTasks.length,
                  Colors.blue,
                  'عدد المهام التي يتم العمل عليها حالياً',
                ),
                SizedBox(height: 16),
                _buildStatusCard(
                  'المهام في الانتظار',
                  pendingTasks.length,
                  Colors.orange,
                  'عدد المهام التي تنتظر البدء بها',
                ),
                SizedBox(height: 24),
                // قسم توزيع المستويات
                _buildPriorityDistribution(allTasks),
              ],
            ),
          );
        },
      ),
    );
  }
}
