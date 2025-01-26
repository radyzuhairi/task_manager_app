import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:task_manager_app/models/user.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('task_manager.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        status INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        due_date TEXT,
        category TEXT
      )
    ''');
  }

  // إنشاء مهمة
  Future<TaskModel> createTask(TaskModel task) async {
    final db = await database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  // استرجاع جميع المهام
  Future<List<TaskModel>> getAllTasks() async {
    final db = await database;
    final taskMaps = await db.query('tasks');
    return taskMaps.map((map) => TaskModel.fromMap(map)).toList();
  }

  // استرجاع المهام حسب الحالة
  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final db = await database;
    final taskMaps = await db.query(
      'tasks', 
      where: 'status = ?', 
      whereArgs: [status.index]
    );
    return taskMaps.map((map) => TaskModel.fromMap(map)).toList();
  }

  // تحديث مهمة
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    return await db.update(
      'tasks', 
      task.toMap(), 
      where: 'id = ?', 
      whereArgs: [task.id]
    );
  }

  // حذف مهمة
  Future<int> deleteTask(int taskId) async {
    final db = await database;
    return await db.delete(
      'tasks', 
      where: 'id = ?', 
      whereArgs: [taskId]
    );
  }

  getUserByEmail(String savedEmail) {}

  createUser(UserModel user) {}
}

