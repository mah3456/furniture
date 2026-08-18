class UserEntity {
  final int? id;
  final String name;
  final String email;
  final String phone;
  final String? password;


  UserEntity({this.id , required this.name, required this.email, required this.phone, this.password});




  @override
  List<Object?> get props => [id, name , phone, email, password];
}