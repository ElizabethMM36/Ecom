class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final int? age;
  final String? phone;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.age,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      email: json['email'],
      profilePicture: json['profilePicture'],
      age: json['age'],
      phone: json['phone'],
    );
  }
}
