import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/debt.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('debts.db');
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

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE debts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        isPaid INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertDebt(Debt debt) async {
    final db = await database;
    return await db.insert('debts', debt.toMap());
  }

  Future<List<Debt>> getAllDebts() async {
    final db = await database;
    final result = await db.query('debts', orderBy: 'date DESC');
    return result.map((map) => Debt.fromMap(map)).toList();
  }

  Future<List<Debt>> getUnpaidDebts() async {
    final db = await database;
    final result = await db.query(
      'debts',
      where: 'isPaid = ?',
      whereArgs: [0],
      orderBy: 'date DESC',
    );
    return result.map((map) => Debt.fromMap(map)).toList();
  }

  Future<List<Debt>> getPaidDebts() async {
    final db = await database;
    final result = await db.query(
      'debts',
      where: 'isPaid = ?',
      whereArgs: [1],
      orderBy: 'date DESC',
    );
    return result.map((map) => Debt.fromMap(map)).toList();
  }

  Future<int> updateDebt(Debt debt) async {
    final db = await database;
    return await db.update(
      'debts',
      debt.toMap(),
      where: 'id = ?',
      whereArgs: [debt.id],
    );
  }

  Future<int> deleteDebt(int id) async {
    final db = await database;
    return await db.delete(
      'debts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Debt>> searchDebts(String query) async {
    final db = await database;
    final result = await db.query(
      'debts',
      where: 'customerName LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );
    return result.map((map) => Debt.fromMap(map)).toList();
  }
}
