import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory_manage/database/firestore_service.dart';
import 'package:inventory_manage/models/category.dart';

class CategoryRepository {
  Future<List<Category>> getAll() async {
    final result = await FirestoreService.collection(
      'category',
    ).orderBy('id').get();
    return result.docs.map((e) => Category.fromMap(e.data())).toList();
  }

  Future<void> insert(Category category) async {
    final id = category.id ?? await FirestoreService.nextId('category');
    await FirestoreService.collection(
      'category',
    ).doc(id.toString()).set({...category.toMap(), 'id': id});
  }

  Future<void> delete(int id) async {
    await FirestoreService.collection('category').doc(id.toString()).delete();
  }
}
