import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'jeda.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE target_app (
        package_name TEXT PRIMARY KEY,
        app_label TEXT NOT NULL,
        icon_base64 TEXT,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        default_countdown_sec INTEGER NOT NULL DEFAULT 5,
        protection_level TEXT NOT NULL DEFAULT 'gentle',
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE motivation_message (
        id TEXT PRIMARY KEY,
        text TEXT NOT NULL,
        category TEXT NOT NULL,
        tone TEXT NOT NULL DEFAULT 'gentle',
        is_enabled INTEGER NOT NULL DEFAULT 1,
        weight INTEGER NOT NULL DEFAULT 5,
        target_package_name TEXT,
        last_shown_at INTEGER,
        helpful_rating INTEGER,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_commitment (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL UNIQUE,
        text TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        morning_created_at INTEGER NOT NULL,
        evening_review_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE interception_event (
        id TEXT PRIMARY KEY,
        package_name TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        countdown_sec INTEGER NOT NULL,
        message_id TEXT,
        commitment_id TEXT,
        user_action TEXT NOT NULL,
        reason TEXT,
        protection_level TEXT NOT NULL DEFAULT 'gentle'
      )
    ''');

    await db.execute('''
      CREATE TABLE relapse_journal (
        id TEXT PRIMARY KEY,
        occurred_at INTEGER NOT NULL,
        package_name TEXT,
        trigger TEXT NOT NULL,
        emotion TEXT NOT NULL,
        intensity INTEGER NOT NULL DEFAULT 3,
        note TEXT,
        next_action TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE focus_session (
        id TEXT PRIMARY KEY,
        started_at INTEGER NOT NULL,
        ended_at INTEGER,
        duration_minutes INTEGER NOT NULL,
        protection_level TEXT NOT NULL DEFAULT 'gentle',
        target_packages_json TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active'
      )
    ''');

    await db.execute('''
      CREATE TABLE achievement (
        id TEXT PRIMARY KEY,
        unlocked_at INTEGER,
        progress INTEGER NOT NULL DEFAULT 0,
        target INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE user_goal (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        primary_goal TEXT NOT NULL,
        goal_text TEXT,
        subgoals TEXT,
        show_in_popup INTEGER NOT NULL DEFAULT 1,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_interception_package ON interception_event(package_name)');
    await db.execute('CREATE INDEX idx_interception_started ON interception_event(started_at)');
    await db.execute('CREATE INDEX idx_journal_occurred ON relapse_journal(occurred_at)');
    await db.execute('CREATE INDEX idx_commitment_date ON daily_commitment(date)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future migrations here
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _db = null;
  }
}
