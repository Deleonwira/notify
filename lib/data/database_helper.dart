import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note_models.dart';
import '../models/activity_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'flutter_notes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        createdAt TEXT,
        color INTEGER,
        category TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE activities(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        type TEXT,
        date TEXT,
        isCompleted INTEGER,
        description TEXT,
        startTime TEXT,
        endTime TEXT,
        priority TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE subtasks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activityId INTEGER,
        title TEXT,
        isCompleted INTEGER,
        FOREIGN KEY (activityId) REFERENCES activities (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');
    await db.execute(
      "INSERT INTO categories (name) VALUES ('Work'), ('Personal'), ('Ideas'), ('Study')",
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN category TEXT;');
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE
        )
      ''');
      await db.execute(
        "INSERT INTO categories (name) VALUES ('Work'), ('Personal'), ('Ideas'), ('Study')",
      );
    }
  }

  // --- Categories ---
  Future<List<String>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<int> insertCategory(String name) async {
    final db = await database;
    return await db.insert('categories', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> deleteCategory(String name) async {
    final db = await database;
    return await db.delete('categories', where: 'name = ?', whereArgs: [name]);
  }

  // --- Notes ---
  Future<int> insertNote(Note note) async {
    final db = await database;
    return await db.insert('notes', note.toMap());
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<int> deleteNote(int id) async {
    final db = await database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateNote(Note note) async {
    final db = await database;
    return await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  // --- Activities ---
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    int activityId = await db.insert('activities', activity.toMap());

    for (var sub in activity.subTasks) {
      var subMap = sub.toMap();
      subMap['activityId'] = activityId;
      await db.insert('subtasks', subMap);
    }
    return activityId;
  }

  Future<List<Activity>> getActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      orderBy: 'date ASC',
    );

    List<Activity> activities = [];
    for (var map in maps) {
      int activityId = map['id'];
      final List<Map<String, dynamic>> subMaps = await db.query(
        'subtasks',
        where: 'activityId = ?',
        whereArgs: [activityId],
      );

      List<SubTask> subTasks = subMaps.map((s) => SubTask.fromMap(s)).toList();

      Activity act = Activity.fromMap(map, subTasks);
      activities.add(act);
    }
    return activities;
  }

  Future<int> deleteActivity(int id) async {
    final db = await database;
    // subtasks should be deleted automatically if CASCADE is working, but just in case:
    await db.delete('subtasks', where: 'activityId = ?', whereArgs: [id]);
    return await db.delete('activities', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    int res = await db.update(
      'activities',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );

    await db.delete(
      'subtasks',
      where: 'activityId = ?',
      whereArgs: [activity.id],
    );
    for (var sub in activity.subTasks) {
      var subMap = sub.toMap();
      subMap['activityId'] = activity.id;
      await db.insert('subtasks', subMap);
    }
    return res;
  }

  Future<int> toggleSubTaskCompletion(int subtaskId, bool isCompleted) async {
    final db = await database;
    return await db.update(
      'subtasks',
      {'isCompleted': isCompleted ? 1 : 0},
      where: 'id = ?',
      whereArgs: [subtaskId],
    );
  }
}
