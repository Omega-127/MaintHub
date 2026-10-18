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

  DateTime? get _nextDateOnly {
    final next = DateTime.tryParse(nextMaintenanceDate);
    if (next == null) return null;
    return DateTime(next.year, next.month, next.day);
  }

  DateTime get _todayOnly {
    final today = DateTime.now();
    return DateTime(today.year, today.month, today.day);
  }

  bool get isOverdue {
    final next = _nextDateOnly;
    if (next == null) return false;
    return next.isBefore(_todayOnly);
  }

  bool get isDueToday {
    final next = _nextDateOnly;
    if (next == null) return false;
    return next == _todayOnly;
  }

  bool get isDueSoon {
    final next = _nextDateOnly;
    if (next == null) return false;
    final diff = next.difference(_todayOnly).inDays;
    return diff >= 0 && diff <= 7;
  }

  int? get daysUntilDue {
    final next = _nextDateOnly;
    if (next == null) return null;
    return next.difference(_todayOnly).inDays;
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
    id:                   (json['id'] as num?)?.toInt() ?? 0,
    name:                 json['name']?.toString() ?? '',
    type:                 json['type']?.toString() ?? '',
    department:           json['department']?.toString() ?? 'BLOWROOM',
    location:             json['location']?.toString(),
    maintenanceInterval:  (json['maintenance_interval'] as num?)?.toInt() ?? 0,
    lastMaintenanceDate:  json['last_maintenance_date']?.toString(),
    nextMaintenanceDate:  json['next_maintenance_date']?.toString() ?? '',
    status:               json['status']?.toString() ?? 'ACTIVE',
  );
}
