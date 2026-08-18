import 'package:stores/Domain/entities/user_entity.dart';

class UserModel extends UserEntity {


  UserModel({
    int? id,
    required String name,
    required String phone,
    required String email,
    String? password,
  }) : super(
    id: id,
    name: name,
    phone: phone,
    email: email,
    password: password,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],  // تعامل مع null
      name: (json['name'] as String?) ?? '',  // تعامل مع null
      phone: (json['phone'] as String?) ?? '',  // تعامل مع null
      email: (json['email'] as String?) ?? '',  // تعامل مع null
      password: json['password'] as String?,  // كلمة المرور يمكن أن تكون null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      password: entity.password,
    );
  }


}