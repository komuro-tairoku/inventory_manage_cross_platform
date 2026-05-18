import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore instance = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> collection(String name) {
    return instance.collection(name);
  }

  static Future<int> nextId(String collectionName) async {
    final snapshot = await collection(collectionName)
        .orderBy('id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 1;
    }

    final value = snapshot.docs.first.data()['id'];
    if (value is num) {
      return value.toInt() + 1;
    }

    return (int.tryParse(value.toString()) ?? 0) + 1;
  }
}