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
  List<Machine> get dueSoonMachines =>
      _machines.where((m) => m.isDueSoon && m.status == 'ACTIVE').toList();

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
    required String department,
    required String location,
    required int    intervalDays,
    required String firstDate,
  }) async {
    try {
      await _service.createMachine(
        name:                name,
        type:                type,
        department:          department,
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
      final nextDate = await _service.markComplete(machineId, notes: notes);
      // Optimistically update
      final index = _machines.indexWhere((m) => m.id == machineId);
      if (index != -1) {
        final m = _machines[index];
        _machines[index] = Machine(
          id: m.id,
          name: m.name,
          type: m.type,
          department: m.department,
          location: m.location,
          maintenanceInterval: m.maintenanceInterval,
          lastMaintenanceDate: DateTime.now().toIso8601String().split('T').first,
          nextMaintenanceDate: nextDate,
          status: 'ACTIVE',
        );
        notifyListeners();
      }
      // Sync in background
      loadMachines();
      return true;
    } catch (e) {
      _error = 'Failed to mark complete';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMachine(int id) async {
    // 1. Optimistically remove immediately from local list so UI updates instantly
    final index = _machines.indexWhere((m) => m.id == id);
    Machine? removedMachine;
    if (index != -1) {
      removedMachine = _machines[index];
      _machines.removeAt(index);
      notifyListeners();
    }

    try {
      await _service.deleteMachine(id);
      // Background re-fetch to ensure sync with server
      _service.getMachines().then((fresh) {
        _machines = fresh;
        notifyListeners();
      }).catchError((_) {});
      return true;
    } catch (e) {
      // Revert optimistic removal on failure
      if (removedMachine != null && !_machines.any((m) => m.id == id)) {
        _machines.insert(index, removedMachine);
        notifyListeners();
      }
      _error = 'Failed to delete machine';
      notifyListeners();
      return false;
    }
  }
}
