import 'package:inventory_manage/database/db_helper.dart';
import 'package:inventory_manage/models/category.dart';

class CategoryRepository {
  final dbHelper = DBHelper();

  Future<List<Category>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('category');
    return result.map((e) => Category.fromMap(e)).toList();
  }

  Future<void> insert(Category category) async {
    final db = await dbHelper.database;
    await db.insert('category', category.toMap());
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete('category', where: 'id = ?', whereArgs: [id]);
  }
}
