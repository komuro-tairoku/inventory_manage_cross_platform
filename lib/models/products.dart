// ignore_for_file: public_member_api_docs, sort_constructors_first
class Products {
  int? id;
  String name;
  double? costPrice;
  double? sellPrice;
  int quantity;
  String? companyName;
  int? categoryId;
  String? createAt;
  String? image;

  Products({
    this.id,
    required this.name,
    this.costPrice,
    this.sellPrice,
    required this.quantity,
    this.companyName,
    this.categoryId,
    this.createAt,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'categoryId': categoryId,
      'costPrice': costPrice,
      'sellPrice': sellPrice,
      'quantity': quantity,
      'createAt': createAt,
      'image': image,
    };
  }

  factory Products.fromMap(Map<String, dynamic> map) {
    return Products(
      id: map['id'],
      name: map['name'] ?? '',
      companyName: map['company_name'],
      categoryId: map['categoryId'],
      costPrice: map['costPrice']?.toDouble(),
      sellPrice: map['sellPrice']?.toDouble(),
      quantity: map['quantity'] ?? 0,
      createAt: map['createAt'],
      image: map['image'],
    );
  }

  double get profitPerItem {
    if (sellPrice == null || costPrice == null) return 0;
    return sellPrice! - costPrice!;
  }
}
