class AppNotification {
  final int id;
  final int machineId;
  final String title;
  final String message;
  final String notificationType; // 'OVERDUE' | 'REMINDER' | 'COMPLETED'
  bool isRead;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.machineId,
    required this.title,
    required this.message,
    required this.notificationType,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int? ?? 0,
      machineId: json['machine_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      notificationType: (json['notification_type'] as String? ?? 'REMINDER').toUpperCase(),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  bool get isOverdue => notificationType == 'OVERDUE';
  bool get isReminder => notificationType == 'REMINDER';
  bool get isCompleted => notificationType == 'COMPLETED';
}
