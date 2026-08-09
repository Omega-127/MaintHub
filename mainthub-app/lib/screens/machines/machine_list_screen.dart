import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/machine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machine_provider.dart';
import 'add_machine_screen.dart';
import 'machine_details_screen.dart';

class MachineListScreen extends StatefulWidget {
  const MachineListScreen({super.key});

  @override
  State<MachineListScreen> createState() => _MachineListScreenState();
}

class _MachineListScreenState extends State<MachineListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MachineProvider>().loadMachines());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final auth     = context.watch<AuthProvider>();

    final filtered = provider.machines
        .where((m) => m.name.toLowerCase().contains(_search.toLowerCase()) ||
                      m.type.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Machines'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: provider.loadMachines),
        ],
      ),
      floatingActionButton: auth.user?.isAdmin == true
          ? FloatingActionButton(
              backgroundColor: AppTheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMachineScreen()),
              ).then((_) => provider.loadMachines()),
            )
          : null,
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText:  'Search machines...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No machines found'))
                    : ListView.builder(
                        padding:     const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:   filtered.length,
                        itemBuilder: (_, i) => _MachineCard(machine: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MachineCard extends StatelessWidget {
  final Machine machine;
  const _MachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    final color  = machine.isOverdue ? AppTheme.danger : AppTheme.success;
    final label  = machine.isOverdue ? 'OVERDUE' : machine.isDueToday ? 'DUE TODAY' : 'OK';
    final next   = DateFormat('dd MMM yyyy').format(DateTime.parse(machine.nextMaintenanceDate));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MachineDetailScreen(machine: machine)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.precision_manufacturing, color: color),
        ),
        title: Text(machine.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${machine.type} • ${machine.location ?? 'No location'}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text('Next: $next', style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
