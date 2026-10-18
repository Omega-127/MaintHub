import '../api_client.dart';
import '../models/app_notification.dart';

class NotificationService {
  final _client = ApiClient();

  Future<List<AppNotification>> getNotifications() async {
    final response = await _client.get('/notifications/');
    final data = response.data;
    if (data is List) {
      return data
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _client.put('/notifications/$notificationId/read');
    } catch (_) {}
  }
}
