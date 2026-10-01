class Machine {
  final int     id;
  final String  name;
  final String  type;
  final String  department; // 'BLOWROOM' | 'COMBER' | 'RING_FRAME' | 'SPEED_FRAME' | 'WINDING' | 'BUFFING'
  final String? location;
  final int     maintenanceInterval;
  final String? lastMaintenanceDate;
  final String  nextMaintenanceDate;
  final String  status;

  Machine({
    required this.id,
    required this.name,
    required this.type,
    required this.department,
    this.location,
    required this.maintenanceInterval,
    this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.status,
  });

  bool get isOverdue {
    final next = DateTime.tryParse(nextMaintenanceDate);
    if (next == null) return false;
    return next.isBefore(DateTime.now());
  }

  bool get isDueToday {
    final next = DateTime.tryParse(nextMaintenanceDate);
    if (next == null) return false;
    final today = DateTime.now();
    return next.year == today.year &&
           next.month == today.month &&
           next.day == today.day;
  }

  /// Human-readable department label
  String get departmentLabel {
    switch (department) {
      case 'COMBER':      return 'Comber';
      case 'RING_FRAME':  return 'Ring Frame';
      case 'SPEED_FRAME': return 'Speed Frame';
      case 'WINDING':     return 'Winding';
      case 'BUFFING':     return 'Buffing';
      default:            return 'Blowroom';
    }
  }

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
    id:                   json['id'],
    name:                 json['name'],
    type:                 json['type'],
    department:           json['department'] ?? 'BLOWROOM',
    location:             json['location'],
    maintenanceInterval:  json['maintenance_interval'],
    lastMaintenanceDate:  json['last_maintenance_date'],
    nextMaintenanceDate:  json['next_maintenance_date'],
    status:               json['status'],
  );
}
