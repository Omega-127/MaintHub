import '../models/machine.dart';
import 'api_client.dart';

class MachineService {
  final _client = ApiClient();

  Future<List<Machine>> getMachines() async {
    final response = await _client.get('/machines/');
    return (response.data as List)
        .map((json) => Machine.fromJson(json))
        .toList();
  }

  Future<Machine> getMachine(int id) async {
    final response = await _client.get('/machines/$id');
    return Machine.fromJson(response.data);
  }

  Future<void> createMachine({
    required String name,
    required String type,
    required String location,
    required int    intervalDays,
    required String firstMaintenanceDate, // YYYY-MM-DD
  }) async {
    await _client.post('/machines/', data: {
      'name':                   name,
      'type':                   type,
      'location':               location,
      'maintenance_interval':   intervalDays,
      'first_maintenance_date': firstMaintenanceDate,
    });
  }

  Future<void> deleteMachine(int id) async {
    await _client.delete('/machines/$id');
  }

  Future<String> markComplete(int machineId, {String notes = ''}) async {
    final response = await _client.post(
      '/maintenance/$machineId/complete',
      data: {'notes': notes},
    );
    return response.data['next_maintenance_date'];
  }
}
