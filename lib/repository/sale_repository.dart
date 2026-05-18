import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_manage/database/firestore_service.dart';
import 'package:inventory_manage/models/sale.dart';

class SaleRepository {
  Future<List<Sale>> getAll() async {
    final result = await FirestoreService.collection(
      'sales',
    ).orderBy('id').get();

    return result.docs.map((e) => Sale.fromMap(e.data())).toList();
  }

  Future<void> insert(Sale sale) async {
    final id = sale.id ?? await FirestoreService.nextId('sales');
    final db = FirestoreService.instance;
    final saleRef = db.collection('sales').doc(id.toString());
    final productRef = db.collection('products').doc(sale.productId.toString());

    await db.runTransaction((txn) async {
      final productSnap = await txn.get(productRef);
      if (!productSnap.exists) {
        throw Exception('Không tìm thấy sản phẩm');
      }

      final currentQty =
          (productSnap.data()?['quantity'] as num?)?.toInt() ?? 0;
      if (sale.quantity > currentQty) {
        throw Exception('Không đủ hàng trong kho');
      }

      txn.set(saleRef, {...sale.toMap(), 'id': id});
      txn.update(productRef, {'quantity': currentQty - sale.quantity});
    });
  }

  Future<double> getTotalProfit() async {
    final result = await FirestoreService.collection('sales').get();
    return result.docs.fold<double>(
      0,
      (total, doc) => total + ((doc.data()['profit'] as num?)?.toDouble() ?? 0),
    );
  }
}
