class User {
  final int     id;
  final String  fullName;
  final String  email;
  final String  role;
  final String? department; // 'BLOWROOM' | 'COMBER' | 'RING_FRAME' | 'SPEED_FRAME' | 'WINDING' | 'BUFFING' | null (Admin sees all)

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
      case 'BLOWROOM':    return 'Blowroom';
      case 'COMBER':      return 'Comber';
      case 'RING_FRAME':  return 'Ring Frame';
      case 'SPEED_FRAME': return 'Speed Frame';
      case 'WINDING':     return 'Winding';
      case 'BUFFING':     return 'Buffing';
      default:            return 'All Departments';
    }
  }

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:         json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    fullName:   (json['full_name'] ?? json['name'] ?? '').toString(),
    email:      (json['email'] ?? '').toString(),
    role:       (json['role'] ?? 'TECHNICIAN').toString(),
    department: json['department']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'full_name':  fullName,
    'email':      email,
    'role':       role,
    'department': department,
  };
}
