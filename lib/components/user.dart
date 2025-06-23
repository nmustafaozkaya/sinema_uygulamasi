class User {
  final int userId;
  final String userName;
  final String userEmail;
  final int userRoleId;
  final int? cinemaId;
  final String accessToken;

  User({
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userRoleId,
    this.cinemaId,
    required this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? 0,
      userName: json['user_name'] ?? json['name'] ?? '',
      userEmail: json['user_email'] ?? json['email'] ?? '',
      userRoleId: json['user_role_id'] ?? 0,
      cinemaId: json['cinema_id'],
      accessToken: json['access_token'] ?? '',
    );
  }
}
