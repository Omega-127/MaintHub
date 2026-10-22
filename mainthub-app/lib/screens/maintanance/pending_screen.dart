import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/machine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machine_provider.dart';
import '../machines/machine_details_screen.dart';

class PendingMaintenanceScreen extends StatefulWidget {
  final String? department;
  const PendingMaintenanceScreen({super.key, this.department});

  @override
  State<PendingMaintenanceScreen> createState() => _PendingMaintenanceScreenState();
}

class _PendingMaintenanceScreenState extends State<PendingMaintenanceScreen> {
  String  _search          = '';
  String? _activeDeptFilter; // null = all (admin only)

  @override
  void initState() {
    super.initState();
    _activeDeptFilter = widget.department;
    Future.microtask(() => context.read<MachineProvider>().loadMachines());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MachineProvider>();
    final auth     = context.watch<AuthProvider>();
    final isAdmin  = auth.user?.isAdmin == true;

    // Title: department-scoped or general
    final title = switch (widget.department) {
      'BLOWROOM'    => 'Blowroom Overdue',
      'COMBER'      => 'Comber Overdue',
      'RING_FRAME'  => 'Ring Frame Overdue',
      'SPEED_FRAME' => 'Speed Frame Overdue',
      'WINDING'     => 'Winding Overdue',
      'BUFFING'     => 'Buffing Overdue',
      _             => 'Overdue Maintenance',
    };

    // Filter: search + optional department
    final filtered = provider.overdueMachines.where((m) {
      final matchSearch = m.name.toLowerCase().contains(_search.toLowerCase()) ||
                          m.type.toLowerCase().contains(_search.toLowerCase());
      final matchDept   = _activeDeptFilter == null || m.department == _activeDeptFilter;
      return matchSearch && matchDept;
    }).toList();

    filtered.sort((a, b) => a.nextMaintenanceDate.compareTo(b.nextMaintenanceDate));

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Admin-only department filter chips
          if (isAdmin && widget.department == null) ...[
            _DeptFilterChip(
              label: 'All',
              selected: _activeDeptFilter == null,
              onTap: () => setState(() => _activeDeptFilter = null),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Blowroom',
              selected: _activeDeptFilter == 'BLOWROOM',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'BLOWROOM' ? null : 'BLOWROOM'),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Comber',
              selected: _activeDeptFilter == 'COMBER',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'COMBER' ? null : 'COMBER'),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Ring Frame',
              selected: _activeDeptFilter == 'RING_FRAME',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'RING_FRAME' ? null : 'RING_FRAME'),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Speed Frame',
              selected: _activeDeptFilter == 'SPEED_FRAME',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'SPEED_FRAME' ? null : 'SPEED_FRAME'),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Winding',
              selected: _activeDeptFilter == 'WINDING',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'WINDING' ? null : 'WINDING'),
            ),
            const SizedBox(width: 4),
            _DeptFilterChip(
              label: 'Buffing',
              selected: _activeDeptFilter == 'BUFFING',
              onTap: () => setState(() =>
                  _activeDeptFilter = _activeDeptFilter == 'BUFFING' ? null : 'BUFFING'),
            ),
            const SizedBox(width: 8),
          ],
          IconButton(icon: const Icon(Icons.refresh), onPressed: provider.loadMachines),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText:  'Search overdue machines...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),

          // Active filter label for technicians
          if (!isAdmin && auth.user?.department != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppTheme.textLight),
                  const SizedBox(width: 6),
                  Text(
                    'Showing: ${auth.user!.departmentLabel} department',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),

          // List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 72, color: AppTheme.success),
                            const SizedBox(height: 16),
                            Text(
                              _search.isNotEmpty || _activeDeptFilter != null
                                  ? 'No matching overdue machines'
                                  : 'All machines are up to date!',
                              style: const TextStyle(fontSize: 18, color: AppTheme.success, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding:     const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount:   filtered.length,
                        itemBuilder: (_, i) => _OverdueMachineCard(machine: filtered[i]),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Small filter chip for admin dept filtering
class _DeptFilterChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _DeptFilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(label, style: TextStyle(
          fontSize:   11,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color:      selected ? Colors.white : AppTheme.textDark,
        )),
        backgroundColor: selected ? AppTheme.primary : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _OverdueMachineCard extends StatelessWidget {
  final Machine machine;
  const _OverdueMachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final next      = DateFormat('dd MMM yyyy').format(DateTime.parse(machine.nextMaintenanceDate));

    // Dept badge color
    final deptColor = machine.department == 'COMBER'
        ? const Color(0xFF7B61FF)
        : machine.department == 'RING_FRAME'
            ? const Color(0xFF00897B)
            : machine.department == 'SPEED_FRAME'
                ? const Color(0xFFE65100)
                : machine.department == 'WINDING'
                    ? const Color(0xFF6A1B9A)
                    : machine.department == 'BUFFING'
                        ? const Color(0xFF00695C)
                        : const Color(0xFF0077B6);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MachineDetailScreen(machine: machine)),
          );
          if (result == true && context.mounted) {
            context.read<MachineProvider>().loadMachines();
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppTheme.danger.withOpacity(0.15),
          radius: 24,
          child: const Icon(Icons.warning_rounded, color: AppTheme.danger),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                machine.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // Department badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: deptColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                machine.departmentLabel,
                style: textTheme.labelSmall?.copyWith(
                  color: deptColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 9,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${machine.type} • ${machine.location ?? 'No location'}',
              style: textTheme.bodySmall?.copyWith(color: AppTheme.textLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Due: $next',
              style: textTheme.bodySmall?.copyWith(color: AppTheme.danger, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.danger.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'OVERDUE',
            style: textTheme.labelSmall?.copyWith(
              color: AppTheme.danger,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
