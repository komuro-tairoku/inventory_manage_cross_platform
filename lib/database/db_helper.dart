import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    _db ??= await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'products.db'),
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE products(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          company_name TEXT,
          categoryId INTEGER,
          costPrice REAL,
          sellPrice REAL,
          quantity INTEGER DEFAULT 0,
          createAt TEXT,
          image TEXT,
          FOREIGN KEY (categoryId) REFERENCES category(id)
        )
        ''');
        await db.execute('''
        CREATE TABLE category(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          icon TEXT,
          color TEXT
        )
        ''');
        await db.execute('''
        CREATE TABLE imports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        quantity INTEGER,
        importPrice REAL,
        date TEXT,
          FOREIGN KEY (productId) REFERENCES products(id)
        )
        ''');

        await db.execute('''
        CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER,
        quantity INTEGER,
        sellPrice REAL,
        profit REAL,
        date TEXT,
        FOREIGN KEY (productId) REFERENCES products(id)
        )
        ''');
      },
    );
  }
}
