import 'package:flutter/material.dart';
import '../models/machine.dart';
import '../services/machine_service.dart';

class MachineProvider extends ChangeNotifier {
  final _service = MachineService();

  List<Machine> _machines   = [];
  bool          _isLoading  = false;
  String        _error      = '';

  List<Machine> get machines       => _machines;
  bool          get isLoading      => _isLoading;
  String        get error          => _error;
  List<Machine> get overdueMachines =>
      _machines.where((m) => m.isOverdue && m.status == 'ACTIVE').toList();

  Future<void> loadMachines() async {
    _isLoading = true;
    _error     = '';
    notifyListeners();

    try {
      _machines  = await _service.getMachines();
      _isLoading = false;
    } catch (e) {
      _error     = 'Failed to load machines';
      _isLoading = false;
    }
    notifyListeners();
  }

  Future<bool> createMachine({
    required String name,
    required String type,
    required String location,
    required int    intervalDays,
    required String firstDate,
  }) async {
    try {
      await _service.createMachine(
        name:                name,
        type:                type,
        location:            location,
        intervalDays:        intervalDays,
        firstMaintenanceDate: firstDate,
      );
      await loadMachines(); // refresh list
      return true;
    } catch (e) {
      _error = 'Failed to create machine';
      notifyListeners();
      return false;
    }
  }

  Future<bool> markComplete(int machineId, {String notes = ''}) async {
    try {
      await _service.markComplete(machineId, notes: notes);
      await loadMachines(); // refresh list
      return true;
    } catch (e) {
      _error = 'Failed to mark complete';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMachine(int id) async {
    try {
      await _service.deleteMachine(id);
      await loadMachines();
      return true;
    } catch (e) {
      _error = 'Failed to delete machine';
      notifyListeners();
      return false;
    }
  }
}
