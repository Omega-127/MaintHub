import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/machine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machine_provider.dart';

class MachineDetailScreen extends StatefulWidget {
  final Machine machine;
  const MachineDetailScreen({super.key, required this.machine});

  @override
  State<MachineDetailScreen> createState() => _MachineDetailScreenState();
}

class _MachineDetailScreenState extends State<MachineDetailScreen> {
  final _notesCtrl = TextEditingController();

  Future<void> _markComplete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Complete?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Mark maintenance for "${widget.machine.name}" as completed?'),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText: 'What was done?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final success = await context.read<MachineProvider>().markComplete(
      widget.machine.id,
      notes: _notesCtrl.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? '✅ Maintenance completed!' : '❌ Failed to update'),
      backgroundColor: success ? AppTheme.success : AppTheme.danger,
    ));
    if (success) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Machine?'),
        content: Text('Are you sure you want to delete "${widget.machine.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    final success = await context.read<MachineProvider>().deleteMachine(widget.machine.id);
    if (!mounted) return;
    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final m    = widget.machine;
    final auth = context.watch<AuthProvider>();
    final next = DateFormat('dd MMM yyyy').format(DateTime.parse(m.nextMaintenanceDate));
    final last = m.lastMaintenanceDate != null
        ? DateFormat('dd MMM yyyy').format(DateTime.parse(m.lastMaintenanceDate!))
        : 'Never';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(m.name),
        actions: [
          if (auth.user?.isAdmin == true)
            IconButton(icon: const Icon(Icons.delete), color: Colors.white, onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: m.isOverdue
                    ? AppTheme.danger.withOpacity(0.08)
                    : AppTheme.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: m.isOverdue ? AppTheme.danger.withOpacity(0.5) : AppTheme.success.withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    m.isOverdue ? Icons.warning_rounded : Icons.check_circle,
                    color: m.isOverdue ? AppTheme.danger : AppTheme.success,
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      m.isOverdue ? 'Overdue — needs immediate attention' : 'Maintenance up to date',
                      style: textTheme.titleMedium?.copyWith(
                        color: m.isOverdue ? AppTheme.danger : AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Details
            Text(
              'Machine Details',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _DetailRow('Name',      m.name),
                    _DetailRow('Type',      m.type),
                    _DetailRow('Location',  m.location ?? 'Not set'),
                    _DetailRow('Status',    m.status),
                    _DetailRow('Interval',  '${m.maintenanceInterval} days'),
                    _DetailRow('Last Maintenance', last),
                    _DetailRow('Next Maintenance', next),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Mark complete button (all roles can mark complete)
            ElevatedButton.icon(
              onPressed: _markComplete,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Mark Maintenance Complete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: textTheme.bodyMedium?.copyWith(color: AppTheme.textLight)),
          ),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
