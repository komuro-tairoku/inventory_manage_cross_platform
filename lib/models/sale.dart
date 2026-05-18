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
    int? readInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    double readDouble(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    DateTime readDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(0);
      }
      if (value != null && value.toString().contains('Timestamp')) {
        final seconds = value.seconds as int?;
        final nanoseconds = value.nanoseconds as int? ?? 0;
        if (seconds != null) {
          return DateTime.fromMillisecondsSinceEpoch(
            seconds * 1000 + (nanoseconds / 1000000).round(),
          );
        }
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return Sale(
      id: readInt(map['id']),
      productId: readInt(map['productId']) ?? 0,
      quantity: readInt(map['quantity']) ?? 0,
      sellPrice: readDouble(map['sellPrice']),
      profit: readDouble(map['profit']),
      date: readDate(map['date']),
    );
  }
}
