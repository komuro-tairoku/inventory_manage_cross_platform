import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_manage/database/firestore_service.dart';
import 'package:inventory_manage/models/imports.dart';

class ImportRepository {
  Future<void> insert(Imports import) async {
    final id = import.id ?? await FirestoreService.nextId('imports');
    final db = FirestoreService.instance;
    final importRef = db.collection('imports').doc(id.toString());
    final productRef = db
        .collection('products')
        .doc(import.productId.toString());

    await db.runTransaction((txn) async {
      final productSnap = await txn.get(productRef);
      if (!productSnap.exists) {
        throw Exception('Không tìm thấy sản phẩm');
      }

      final currentQuantity =
          (productSnap.data()?['quantity'] as num?)?.toInt() ?? 0;
      txn.set(importRef, {...import.toMap(), 'id': id});
      txn.update(productRef, {'quantity': currentQuantity + import.quantity});
    });
  }

  Future<List<Imports>> getAll() async {
    final result = await FirestoreService.collection(
      'imports',
    ).orderBy('id').get();
    return result.docs.map((e) => Imports.fromMap(e.data())).toList();
  }
}
