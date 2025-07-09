// user.dart

class User {
  final int id;
  final String name;
  final String email;
  final int roleId;
  final int? cinemaId;
  final bool isActive;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roleId,
    this.cinemaId,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] ?? 0,
      cinemaId: json['cinema_id'],
      isActive: json['is_active'] is bool
          ? json['is_active']
          : json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
      'cinema_id': cinemaId,
      'is_active': isActive,
    };
  }
}
