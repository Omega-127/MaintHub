import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/machine_provider.dart';

class AddMachineScreen extends StatefulWidget {
  const AddMachineScreen({super.key});

  @override
  State<AddMachineScreen> createState() => _AddMachineScreenState();
}

class _AddMachineScreenState extends State<AddMachineScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _typeCtrl       = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _intervalCtrl   = TextEditingController();
  DateTime? _firstDate;

  @override
  void dispose() {
    _nameCtrl.dispose(); _typeCtrl.dispose();
    _locationCtrl.dispose(); _intervalCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _firstDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_firstDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select first maintenance date')),
      );
      return;
    }

    final success = await context.read<MachineProvider>().createMachine(
      name:        _nameCtrl.text.trim(),
      type:        _typeCtrl.text.trim(),
      location:    _locationCtrl.text.trim(),
      intervalDays: int.parse(_intervalCtrl.text.trim()),
      firstDate:   DateFormat('yyyy-MM-dd').format(_firstDate!),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Machine added!'), backgroundColor: AppTheme.success),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to add machine'), backgroundColor: AppTheme.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Add Machine')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(_nameCtrl,     'Machine Name',       'e.g. Pump-001'),
              _field(_typeCtrl,     'Type',               'e.g. Pump, Motor, Loom'),
              _field(_locationCtrl, 'Location',           'e.g. Hall A, Floor 2'),
              _field(_intervalCtrl, 'Maintenance Interval (days)', 'e.g. 90',
                  keyboardType: TextInputType.number),

              const SizedBox(height: 16),
              const Text('First Maintenance Date',
                  style: TextStyle(fontSize: 14, color: AppTheme.textLight)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickDate,
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
                      const Icon(Icons.calendar_today, color: AppTheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        _firstDate != null
                            ? DateFormat('dd MMM yyyy').format(_firstDate!)
                            : 'Select date',
                        style: TextStyle(
                          color: _firstDate != null ? AppTheme.textDark : AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _submit, child: const Text('Add Machine')),
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
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextFormField(
          controller:   ctrl,
          keyboardType: keyboardType,
          decoration:   InputDecoration(labelText: label, hintText: hint),
          validator:    (v) => v == null || v.isEmpty ? '$label is required' : null,
        ),
      );
}

