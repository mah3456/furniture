import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String? id;
  final String name;

  final String type;
  final String? Userid;
  final double price;
  final String description;
  final String? username;

   Product({
    this.id,
    this.Userid,
    this.username,
    required this.description,
    required this.name,
    required this.type,
    required this.price,
  });

  @override
  List<Object?> get props => [id, Userid, username,  description, name, type, price];
}