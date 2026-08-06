class Machine {
  final int     id;
  final String  name;
  final String  type;
  final String? location;
  final int     maintenanceInterval;
  final String? lastMaintenanceDate;
  final String  nextMaintenanceDate;
  final String  status;

  Machine({
    required this.id,
    required this.name,
    required this.type,
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

  factory Machine.fromJson(Map<String, dynamic> json) => Machine(
    id:                   json['id'],
    name:                 json['name'],
    type:                 json['type'],
    location:             json['location'],
    maintenanceInterval:  json['maintenance_interval'],
    lastMaintenanceDate:  json['last_maintenance_date'],
    nextMaintenanceDate:  json['next_maintenance_date'],
    status:               json['status'],
  );
}
