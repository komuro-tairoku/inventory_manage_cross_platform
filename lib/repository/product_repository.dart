import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_manage/database/firestore_service.dart';
import 'package:inventory_manage/models/product.dart';

class ProductRepository {
  Future<List<Product>> getAll() async {
    final result = await FirestoreService.collection(
      'products',
    ).orderBy('id').get();
    return result.docs.map((e) => Product.fromMap(e.data())).toList();
  }

  Future<Product?> getById(int id) async {
    final result = await FirestoreService.collection(
      'products',
    ).doc(id.toString()).get();

    if (result.exists) {
      return Product.fromMap(result.data()!);
    }

    return null;
  }

  Future<Product?> getByBarcode(String barcode) async {
    final result = await FirestoreService.collection(
      'products',
    ).where('barcode', isEqualTo: barcode).limit(1).get();

    if (result.docs.isEmpty) {
      return null;
    }

    return Product.fromMap(result.docs.first.data());
  }

  Future<void> insert(Product product) async {
    final id = product.id ?? await FirestoreService.nextId('products');
    await FirestoreService.collection(
      'products',
    ).doc(id.toString()).set({...product.toMap(), 'id': id});
  }

  Future<void> update(Product product) async {
    final id = product.id;
    if (id == null) {
      throw ArgumentError('Product id is required for update');
    }

    await FirestoreService.collection('products').doc(id.toString()).set({
      ...product.toMap(),
      'id': id,
    }, SetOptions(merge: true));
  }

  Future<void> delete(int id) async {
    await FirestoreService.collection('products').doc(id.toString()).delete();
  }
}
