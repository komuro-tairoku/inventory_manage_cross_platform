// ignore_for_file: public_member_api_docs, sort_constructors_first
class Category {
  int? id;
  String name;
  String? icon;
  String? color;
  Category({this.id, required this.name, this.icon, this.color});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'icon': icon, 'color': color};
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    int? readInt(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return Category(
      id: readInt(map['id']),
      name: map['name'] ?? '',
      icon: map['icon'],
      color: map['color'],
    );
  }
}
