import 'package:inventory_manage/database/db_helper.dart';
import 'package:inventory_manage/models/products.dart';

class ProductRepository {
  final dbHelper = DBHelper();

  Future<List<Products>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('products');
    return result.map((e) => Products.fromMap(e)).toList();
  }

  Future<Products?> getById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return Products.fromMap(result.first);
    }

    return null;
  }

  Future<void> insert(Products product) async {
    final db = await dbHelper.database;
    await db.insert('products', product.toMap());
  }

  Future<void> update(Products product) async {
    final db = await dbHelper.database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
