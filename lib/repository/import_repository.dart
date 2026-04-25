import 'package:inventory_manage/database/db_helper.dart';
import 'package:inventory_manage/models/imports.dart';

class ImportRepository {
  final dbHelper = DBHelper();

  Future<void> insert(Imports import) async {
    final db = await dbHelper.database;

    await db.transaction((txn) async {
      await txn.insert('imports', import.toMap());

      await txn.rawUpdate(
        'UPDATE products SET quantity = quantity + ? WHERE id = ?',
        [import.quantity, import.productId],
      );
    });
  }

  Future<List<Imports>> getAll() async {
    final db = await dbHelper.database;
    final result = await db.query('imports');
    return result.map((e) => Imports.fromMap(e)).toList();
  }
}
