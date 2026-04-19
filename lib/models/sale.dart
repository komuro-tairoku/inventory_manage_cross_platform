// ignore_for_file: public_member_api_docs, sort_constructors_first
class Sale {
  int? id;
  int productId;
  int quantity;
  double sellPrice;
  double profit;
  DateTime date;
  Sale({
    this.id,
    required this.productId,
    required this.quantity,
    required this.sellPrice,
    required this.profit,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'sellPrice': sellPrice,
      'profit': profit,
      'date': date,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['is'],
      productId: map['productId'],
      quantity: map['quantity'],
      sellPrice: map['sellPrice']?.toDouble() ?? 0,
      profit: map['profit']?.toDouble() ?? 0,
      date: map['date'],
    );
  }
}
