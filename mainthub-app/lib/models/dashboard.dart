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
       totalMachines:    json['total_machines'],
       active:           json['active'],
       inactive:         json['inactive'],
       underMaintenance: json['under_maintenance'],
       overdue:          json['overdue'],
       upcoming7Days:    json['upcoming_7_days'],
  );   
}