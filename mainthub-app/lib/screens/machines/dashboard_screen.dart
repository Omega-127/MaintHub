import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/dashboard.dart';
import '../../providers/auth_provider.dart';
import '../../services/dashboard_service.dart';
import 'login_screen.dart';
import 'machine_list_screen.dart';
import 'add_machine_screen.dart';
import '../maintanance/pending_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dashService = DashboardService();
  DashboardSummary? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final summary = await _dashService.getSummary();
      setState(() { _summary = summary; _isLoading = false; });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth      = context.watch<AuthProvider>();
    final textTheme = Theme.of(context).textTheme;
    final isAdmin   = auth.user?.isAdmin == true;
    final userDept  = auth.user?.department;   // null for admin

    return Scaffold(
      appBar: AppBar(
        title: const Text('MainHub'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
          IconButton(icon: const Icon(Icons.logout),  onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    Text(
                      'Hello, ${auth.user?.fullName ?? 'User'} 👋',
                      style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    // Role + department badge
                    Row(
                      children: [
                        Text(
                          auth.user?.role ?? '',
                          style: textTheme.bodyMedium?.copyWith(color: AppTheme.textLight),
                        ),
                        if (userDept != null) ...[
                          const SizedBox(width: 8),
                          _DeptBadge(department: userDept),
                        ],
                      ],
                    ),
                    const SizedBox(height: 24),

                    // KPI Cards
                    if (_summary != null) ...[
                      _kpiRow([
                        _KpiCard('Total',    _summary!.totalMachines, Icons.precision_manufacturing, AppTheme.primary),
                        _KpiCard('Active',   _summary!.active,        Icons.check_circle,            AppTheme.success),
                      ]),
                      const SizedBox(height: 12),
                      _kpiRow([
                        _KpiCard('Overdue',  _summary!.overdue,       Icons.warning_rounded,         AppTheme.danger),
                        _KpiCard('Due Soon', _summary!.upcoming7Days, Icons.schedule,                AppTheme.warning),
                      ]),
                    ],

                    const SizedBox(height: 28),

                    // Quick Actions
                    Text('Quick Actions', style: textTheme.titleLarge),
                    const SizedBox(height: 12),

                    // --- ADMIN: see all departments ---
                    if (isAdmin) ...[
                      // Blowroom department tile
                      _ActionTile(
                        icon:    Icons.factory_outlined,
                        label:   'Blowroom Machines',
                        color:   const Color(0xFF0077B6),
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MachineListScreen(department: 'BLOWROOM'))),
                      ),
                      const SizedBox(height: 12),
                      // Comber department tile
                      _ActionTile(
                        icon:    Icons.settings_input_component_outlined,
                        label:   'Comber Machines',
                        color:   const Color(0xFF7B61FF),
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MachineListScreen(department: 'COMBER'))),
                      ),
                      const SizedBox(height: 12),
                      // Ring Frame department tile
                      _ActionTile(
                        icon:    Icons.rotate_right_outlined,
                        label:   'Ring Frame Machines',
                        color:   const Color(0xFF00897B),
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MachineListScreen(department: 'RING_FRAME'))),
                      ),
                      const SizedBox(height: 12),
                      // Speed Frame department tile
                      _ActionTile(
                        icon:    Icons.speed_outlined,
                        label:   'Speed Frame Machines',
                        color:   const Color(0xFFE65100),
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MachineListScreen(department: 'SPEED_FRAME'))),
                      ),
                      const SizedBox(height: 12),
                      // All machines
                      _ActionTile(
                        icon:    Icons.list_alt,
                        label:   'All Machines',
                        color:   AppTheme.primary,
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const MachineListScreen())),
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon:    Icons.warning_rounded,
                        label:   'Pending Maintenance',
                        color:   AppTheme.danger,
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PendingMaintenanceScreen())),
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon:    Icons.add_circle,
                        label:   'Add Machine',
                        color:   AppTheme.success,
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddMachineScreen())),
                      ),
                    ],

                    // --- TECHNICIAN: only their department ---
                    if (!isAdmin) ...[
                      _ActionTile(
                        icon:    userDept == 'COMBER'
                                    ? Icons.settings_input_component_outlined
                                    : userDept == 'RING_FRAME'
                                        ? Icons.rotate_right_outlined
                                        : userDept == 'SPEED_FRAME'
                                            ? Icons.speed_outlined
                                            : Icons.factory_outlined,
                        label:   '${auth.user?.departmentLabel ?? ''} Machines',
                        color:   userDept == 'COMBER'
                                    ? const Color(0xFF7B61FF)
                                    : userDept == 'RING_FRAME'
                                        ? const Color(0xFF00897B)
                                        : userDept == 'SPEED_FRAME'
                                            ? const Color(0xFFE65100)
                                            : const Color(0xFF0077B6),
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => MachineListScreen(department: userDept))),
                      ),
                      const SizedBox(height: 12),
                      _ActionTile(
                        icon:    Icons.warning_rounded,
                        label:   'Pending Maintenance',
                        color:   AppTheme.danger,
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const PendingMaintenanceScreen())),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _kpiRow(List<Widget> cards) {
    final list = <Widget>[];
    for (int i = 0; i < cards.length; i++) {
      if (i > 0) list.add(const SizedBox(width: 12));
      list.add(Expanded(child: cards[i]));
    }
    return Row(children: list);
  }
}

/// Small coloured department badge
class _DeptBadge extends StatelessWidget {
  final String department;
  const _DeptBadge({required this.department});

  @override
  Widget build(BuildContext context) {
    final color = department == 'COMBER'
        ? const Color(0xFF7B61FF)
        : department == 'RING_FRAME'
            ? const Color(0xFF00897B)
            : department == 'SPEED_FRAME'
                ? const Color(0xFFE65100)
                : const Color(0xFF0077B6);
    final label = department == 'COMBER'
        ? 'Comber'
        : department == 'RING_FRAME'
            ? 'Ring Frame'
            : department == 'SPEED_FRAME'
                ? 'Speed Frame'
                : 'Blowroom';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final int    value;
  final IconData icon;
  final Color  color;

  const _KpiCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              '$value',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      onTap:   onTap,
      tileColor: color.withOpacity(0.08),
      shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
      title:   Text(label, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
