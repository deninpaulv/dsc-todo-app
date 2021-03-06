import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:todo/Data/model.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "TestDB.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Todo ("
          "id INTEGER PRIMARY KEY,"
          "title TEXT,"
          "description TEXT,"
          "done INT"
          ")");
    });
  }

  newTodoEntry(TodoEntry entry) async {
    final db = await database;
    var res = await db.insert("Todo", entry.toMap());
    return res;
  }

  getAllTodoEntries() async {
    final db = await database;
    var res = await db.query(
      "Todo",
      orderBy: "done" + " DESC",
    );
    List<TodoEntry> list =
        res.isNotEmpty ? res.map((c) => TodoEntry.fromMap(c)).toList() : [];
    return list;
  }

  getTodoEntry(int id) async {
    final db = await database;
    var res = await db.query("Todo", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? TodoEntry.fromMap(res.first) : Null;
  }

  updateTodoEntry(TodoEntry entry) async {
    final db = await database;
    var res = await db
        .update("Todo", entry.toMap(), where: "id = ?", whereArgs: [entry.id]);
    return res;
  }

  deleteTodoEntry(int id) async {
    final db = await database;
    db.delete("Todo", where: "id = ?", whereArgs: [id]);
  }

  deleteAll() async {
    final db = await database;
    db.rawDelete("Delete * from Todo");
  }
}
