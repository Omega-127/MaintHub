import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/machine.dart';
import '../../providers/auth_provider.dart';
import '../../providers/machine_provider.dart';
import '../machines/machine_details_screen.dart';

class DueSoonScreen extends StatefulWidget {
  final String? department;
  const DueSoonScreen({super.key, this.department});

  @override
  State<DueSoonScreen> createState() => _DueSoonScreenState();
}

class _DueSoonScreenState extends State<DueSoonScreen> {
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

    final title = switch (widget.department) {
      'BLOWROOM'    => 'Blowroom Due Soon',
      'COMBER'      => 'Comber Due Soon',
      'RING_FRAME'  => 'Ring Frame Due Soon',
      'SPEED_FRAME' => 'Speed Frame Due Soon',
      'WINDING'     => 'Winding Due Soon',
      'BUFFING'     => 'Buffing Due Soon',
      _             => 'Due Soon Maintenance',
    };

    final filtered = provider.dueSoonMachines.where((m) {
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
                hintText:  'Search due soon machines...',
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
                            const Icon(Icons.event_available, size: 72, color: AppTheme.success),
                            const SizedBox(height: 16),
                            Text(
                              _search.isNotEmpty || _activeDeptFilter != null
                                  ? 'No matching machines due soon'
                                  : 'No machines due for maintenance in the next 7 days',
                              style: const TextStyle(fontSize: 16, color: AppTheme.success, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _DueSoonMachineCard(machine: filtered[i]),
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

class _DueSoonMachineCard extends StatelessWidget {
  final Machine machine;
  const _DueSoonMachineCard({required this.machine});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color     = machine.isDueToday ? AppTheme.danger : AppTheme.warning;
    final badgeText = machine.isDueToday ? 'DUE TODAY' : 'DUE SOON';

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

    final nextParsed = DateTime.parse(machine.nextMaintenanceDate);
    final nextStr    = DateFormat('dd MMM yyyy').format(nextParsed);
    final days       = machine.daysUntilDue ?? 0;
    final daysText   = machine.isDueToday
        ? 'Due today'
        : days == 1
            ? 'Due tomorrow'
            : 'Due in $days days';

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
          radius: 24,
          child: Icon(Icons.schedule, color: color),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                machine.name,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
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
              '$daysText • $nextStr',
              style: textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            badgeText,
            style: textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
