import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/cupertino.dart';
import '../models/note_models.dart';
import '../models/activity_model.dart';
import '../models/category_model.dart';

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
      version: 5,
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
        name TEXT UNIQUE,
        color INTEGER,
        iconCodePoint INTEGER
      )
    ''');
    
    await _insertFixedCategories(db);
  }

  Future<void> _insertFixedCategories(Database db) async {
    final fixedCategories = [
      {'name': 'Work', 'color': 0xFF3B82F6, 'iconCodePoint': CupertinoIcons.briefcase.codePoint},
      {'name': 'Personal', 'color': 0xFF10B981, 'iconCodePoint': CupertinoIcons.person.codePoint},
      {'name': 'Ideas', 'color': 0xFFF59E0B, 'iconCodePoint': CupertinoIcons.lightbulb.codePoint},
      {'name': 'Study', 'color': 0xFF8B5CF6, 'iconCodePoint': CupertinoIcons.book.codePoint},
      {'name': 'Shopping', 'color': 0xFFEC4899, 'iconCodePoint': CupertinoIcons.shopping_cart.codePoint},
      {'name': 'Health', 'color': 0xFFEF4444, 'iconCodePoint': CupertinoIcons.heart.codePoint},
    ];

    for (var cat in fixedCategories) {
      await db.insert('categories', cat, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN category TEXT;');
      await db.execute('''
        CREATE TABLE categories(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT UNIQUE,
          color INTEGER,
          iconCodePoint INTEGER
        )
      ''');
      await _insertFixedCategories(db);
    } else if (oldVersion < 3) {
      await db.execute('ALTER TABLE categories ADD COLUMN color INTEGER;');
      await db.update('categories', {'color': 0xFF7C3AED});
    }
    
    if (oldVersion < 4) {
      // Add iconCodePoint column
      try {
        await db.execute('ALTER TABLE categories ADD COLUMN iconCodePoint INTEGER;');
      } catch (e) {
        // column might already exist from half-baked version 2 if logic was messy
      }
      
      // Clear existing and insert fixed set to satisfy "tiap kategori memiliki warnanya masing masing dan icon"
      await db.delete('categories');
      await _insertFixedCategories(db);
    }
    
    if (oldVersion < 5) {
      // Fix icon codepoints by re-inserting fixed categories
      await db.delete('categories');
      await _insertFixedCategories(db);
    }
  }

  // --- Categories ---
  Future<List<Category>> getCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  // insertCategory and deleteCategory removed to lock the list as requested

  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert('categories', category.toMap());
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
      orderBy: 'date ASC, startTime ASC',
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
