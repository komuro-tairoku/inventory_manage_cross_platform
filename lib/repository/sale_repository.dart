import 'dart:io';

import 'package:inventory_manage/database/db_helper.dart';
import 'package:inventory_manage/models/sale.dart';

class SaleRepository {
  final dbHelper = DBHelper();

  Future<List<Sale>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('sale');

    return result.map((e) => Sale.fromMap(e)).toList();
  }

  Future<void> insert(Sale sale) async {
    final db = await dbHelper.database;
    final product = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [sale.productId],
    );

    int currentQty = product.first['quantity'] as int;

    if (sale.quantity > currentQty) {
      throw Exception("Không đủ hàng trong kho");
    }

    await db.insert('sales', sale.toMap());
    await db.rawUpdate(
      'UPDATE products SET quantity = quantity - ? WHERE id = ?',
      [sale.quantity, sale.productId],
    );
  }

  Future<double> getTotalProfit() async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(profit) as total FROM sales');

    return result.first['total'] == null
        ? 0
        : (result.first['total'] as num).toDouble();
  }
}
