import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/machine_provider.dart';
import '../machines/machine_details_screen.dart';

class PendingMaintenanceScreen extends StatefulWidget {
  const PendingMaintenanceScreen({super.key});

  @override
  State<PendingMaintenanceScreen> createState() => _PendingMaintenanceScreenState();
}

class _PendingMaintenanceScreenState extends State<PendingMaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MachineProvider>().loadMachines());
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<MachineProvider>();
    final overdue   = provider.overdueMachines;

    return Scaffold(
      appBar: AppBar(title: const Text('Pending Maintenance')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : overdue.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 72, color: AppTheme.success),
                      SizedBox(height: 16),
                      Text('All machines are up to date!',
                          style: TextStyle(fontSize: 18, color: AppTheme.success)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:     const EdgeInsets.all(16),
                  itemCount:   overdue.length,
                  itemBuilder: (_, i) {
                    final m    = overdue[i];
                    final next = DateFormat('dd MMM yyyy')
                        .format(DateTime.parse(m.nextMaintenanceDate));
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MachineDetailScreen(machine: m)),
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFEBEE),
                          child: Icon(Icons.warning_rounded, color: AppTheme.danger),
                        ),
                        title: Text(m.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${m.type} • Due: $next\n${m.location ?? 'No location'}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    );
                  },
                ),
    );
  }
}
