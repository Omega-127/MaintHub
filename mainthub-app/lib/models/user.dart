class User {
  final int    id;
  final String fullName;
  final String email;
  final String role;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });

  bool get isAdmin => role == 'ADMIN';

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:       json['id'],
    fullName: json['full_name'],
    email:    json['email'],
    role:     json['role'],
  );
}
