import '../models/dashboard.dart';
import 'api_client.dart';

class DashboardService {
  final _client = ApiClient();

  Future<DashboardSummary> getSummary() async {
    final response = await _client.get('/dashboard/');
    return DashboardSummary.fromJson(response.data['summary']);
  }
}