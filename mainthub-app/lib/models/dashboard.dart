class DashboardSummary {
    final int totalMachines;
    final int active;
    final int inactive;
    final int underMaintenance;
    final int overdue;
    final int upcoming7Days;

    DashboardSummary({
        required this.totalMachines,
        required this.active,
        required this.inactive,
        required this.underMaintenance,
        required this.overdue,
        required this.upcoming7Days,
    });

    factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
       totalMachines:    (json['total_machines'] as num?)?.toInt() ?? 0,
       active:           (json['active'] as num?)?.toInt() ?? 0,
       inactive:         (json['inactive'] as num?)?.toInt() ?? 0,
       underMaintenance: (json['under_maintenance'] as num?)?.toInt() ?? 0,
       overdue:          (json['overdue'] as num?)?.toInt() ?? 0,
       upcoming7Days:    (json['upcoming_7_days'] as num?)?.toInt() ?? 0,
  );   
}