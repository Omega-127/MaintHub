class User {
  final int     id;
  final String  fullName;
  final String  email;
  final String  role;
  final String? department; // 'BLOWROOM' | 'COMBER' | null (Admin sees all)

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.department,
  });

  bool get isAdmin => role == 'ADMIN';

  /// Human-readable department label
  String get departmentLabel {
    switch (department) {
      case 'BLOWROOM': return 'Blowroom';
      case 'COMBER':   return 'Comber';
      default:         return 'All Departments';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:         json['id'],
    fullName:   json['full_name'],
    email:      json['email'],
    role:       json['role'],
    department: json['department'],
  );
}
