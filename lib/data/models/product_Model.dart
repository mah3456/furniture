import '../../Domain/entities/product_entity.dart';

class ProductModel extends Product {

   ProductModel({
    String? id,
    String? Userid,
    String?  username,
    required String name,
    required String type,
    required double price,
    required String description,


  }) : super(
    id: id,
    Userid: Userid,
    username: username,
    name: name,
    type: type,
    description: description,
    price: price,
  );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString(),
      Userid: json['user_id']?.toString(),
      username: json['user_name'].toString(),
      name: (json['name'] as String?) ?? '',
      type: (json['type'] as String?) ?? '',
      description: json['description'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Userid':Userid,
      'name': name,
      'type': type,
      'description':description,
      'price': price,
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      Userid: entity.Userid,
      username: entity.username,
      name: entity.name,
      type: entity.type,
      description: entity.description,
      price: entity.price,
    );
  }
}