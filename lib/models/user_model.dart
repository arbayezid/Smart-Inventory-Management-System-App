class UserModel {
  final String? id;
  final String? email;
  final String? name;
  final String? role;
  final String? shopId; // If shop reference is passed
  final String? shopName;

  UserModel({this.id, this.email, this.name, this.role, this.shopId, this.shopName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? json['firebaseUid'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
      shopId: json['shopId'],
      shopName: json['shopName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'name': name,
      'role': role,
      'shopId': shopId,
      'shopName': shopName,
    };
  }
}
