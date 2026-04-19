// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Imports {
  int? id;
  int productId;
  int quantity;
  double importPrice;
  String date;
  Imports({
    this.id,
    required this.productId,
    required this.quantity,
    required this.importPrice,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'importPrice': importPrice,
      'date': date,
    };
  }

  factory Imports.fromMap(Map<String, dynamic> map) {
    return Imports(
      id: map['id'],
      productId: map['productId'],
      quantity: map['quantity'] ?? 0,
      importPrice: map['importPrice']?.toDouble() ?? 0,
      date: map['date'],
    );
  }
}
