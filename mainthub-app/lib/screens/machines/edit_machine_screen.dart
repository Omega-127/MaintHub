import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/machine.dart';
import '../../providers/machine_provider.dart';

class EditMachineScreen extends StatefulWidget {
  final Machine machine;

  const EditMachineScreen({super.key, required this.machine});

  @override
  State<EditMachineScreen> createState() => _EditMachineScreenState();
}

class _EditMachineScreenState extends State<EditMachineScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _typeCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _intervalCtrl;

  late String _selectedDept;
  late String _selectedStatus;
  DateTime? _lastDate;
  DateTime? _nextDate;

  @override
  void initState() {
    super.initState();
    final m = widget.machine;
    _nameCtrl = TextEditingController(text: m.name);
    _typeCtrl = TextEditingController(text: m.type);
    _locationCtrl = TextEditingController(text: m.location ?? '');
    _intervalCtrl = TextEditingController(text: m.maintenanceInterval.toString());
    _selectedDept = m.department;
    _selectedStatus = m.status;

    if (m.lastMaintenanceDate != null && m.lastMaintenanceDate!.isNotEmpty) {
      _lastDate = DateTime.tryParse(m.lastMaintenanceDate!);
    }
    if (m.nextMaintenanceDate.isNotEmpty) {
      _nextDate = DateTime.tryParse(m.nextMaintenanceDate);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _locationCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLastDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _lastDate = picked;
        // Optionally suggest next maintenance date based on interval
        final interval = int.tryParse(_intervalCtrl.text.trim());
        if (interval != null && interval > 0) {
          _nextDate = picked.add(Duration(days: interval));
        }
      });
    }
  }

  Future<void> _pickNextDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextDate ?? DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _nextDate = picked);
    }
  }

  void _recalculateNextDate() {
    final interval = int.tryParse(_intervalCtrl.text.trim());
    if (_lastDate != null && interval != null && interval > 0) {
      setState(() {
        _nextDate = _lastDate!.add(Duration(days: interval));
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final interval = int.parse(_intervalCtrl.text.trim());
    final lastStr = _lastDate != null ? DateFormat('yyyy-MM-dd').format(_lastDate!) : null;
    final nextStr = _nextDate != null ? DateFormat('yyyy-MM-dd').format(_nextDate!) : null;

    final provider = context.read<MachineProvider>();
    final updated = await provider.updateMachine(
      id: widget.machine.id,
      name: _nameCtrl.text.trim(),
      type: _typeCtrl.text.trim(),
      department: _selectedDept,
      location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
      status: _selectedStatus,
      intervalDays: interval,
      lastMaintenanceDate: lastStr,
      nextMaintenanceDate: nextStr,
    );

    if (!mounted) return;

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Machine updated successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context, updated);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error.isNotEmpty ? provider.error : '❌ Failed to update machine'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Machine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Changes',
            onPressed: provider.isLoading ? null : _submit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(_nameCtrl, 'Machine Name', 'e.g. Card A1 - Flat Brush Change'),
              _field(_typeCtrl, 'Machine Type', 'e.g. Carding, Blowroom, Comber'),
              const SizedBox(height: 4),

              // Department picker
              const Text('Department', style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedDept,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.factory_outlined),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'BLOWROOM', child: Text('Blowroom / Carding')),
                  DropdownMenuItem(value: 'COMBER', child: Text('Comber')),
                  DropdownMenuItem(value: 'RING_FRAME', child: Text('Ring Frame')),
                  DropdownMenuItem(value: 'SPEED_FRAME', child: Text('Speed Frame')),
                  DropdownMenuItem(value: 'WINDING', child: Text('Winding')),
                  DropdownMenuItem(value: 'BUFFING', child: Text('Buffing')),
                ],
                onChanged: (v) => setState(() => _selectedDept = v!),
                validator: (v) => v == null ? 'Select a department' : null,
              ),
              const SizedBox(height: 16),

              _field(_locationCtrl, 'Location', 'e.g. Carding Section, Bay 3'),

              // Status picker
              const Text('Status', style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                  DropdownMenuItem(value: 'UNDER_MAINTENANCE', child: Text('Under Maintenance')),
                  DropdownMenuItem(value: 'INACTIVE', child: Text('Inactive')),
                ],
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
              const SizedBox(height: 16),

              _field(
                _intervalCtrl,
                'Maintenance Interval (days)',
                'e.g. 548',
                keyboardType: TextInputType.number,
                onChanged: (_) => _recalculateNextDate(),
              ),

              const SizedBox(height: 16),
              const Text('Last Maintenance Date', style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickLastDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Text(
                              _lastDate != null
                                  ? DateFormat('dd MMM yyyy').format(_lastDate!)
                                  : 'Not set (Never)',
                              style: TextStyle(
                                color: _lastDate != null ? AppTheme.textDark : AppTheme.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_lastDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      tooltip: 'Clear Last Date',
                      onPressed: () => setState(() => _lastDate = null),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Next Due Date', style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
                  if (_lastDate != null)
                    TextButton.icon(
                      onPressed: _recalculateNextDate,
                      icon: const Icon(Icons.calculate_outlined, size: 16),
                      label: const Text('Calculate from interval', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: _pickNextDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _nextDate != null
                            ? DateFormat('dd MMM yyyy').format(_nextDate!)
                            : 'Select next due date',
                        style: TextStyle(
                          color: _nextDate != null ? AppTheme.textDark : AppTheme.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint, {
    TextInputType keyboardType = TextInputType.text,
    void Function(String)? onChanged,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(labelText: label, hintText: hint),
          validator: (v) => v == null || v.trim().isEmpty ? '$label is required' : null,
        ),
      );
}
