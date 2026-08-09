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
    final auth = context.watch<AuthProvider>();

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
                      style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    const SizedBox(height: 4),
                    Text(auth.user?.role ?? '', style: const TextStyle(color: AppTheme.textLight)),
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

                    // Quick actions
                    const Text('Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _ActionTile(
                      icon:    Icons.list_alt,
                      label:   'All Machines',
                      color:   AppTheme.primary,
                      onTap:   () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MachineListScreen())),
                    ),
                    const SizedBox(height: 10),
                    _ActionTile(
                      icon:    Icons.warning_rounded,
                      label:   'Pending Maintenance',
                      color:   AppTheme.danger,
                      onTap:   () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PendingMaintenanceScreen())),
                    ),
                    if (auth.user?.isAdmin == true) ...[
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon:    Icons.add_circle,
                        label:   'Add Machine',
                        color:   AppTheme.success,
                        onTap:   () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const AddMachineScreen())),
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

class _KpiCard extends StatelessWidget {
  final String label;
  final int    value;
  final IconData icon;
  final Color  color;

  const _KpiCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text('$value',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
        ],
      ),
    ),
  );
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    onTap:   onTap,
    tileColor: color.withOpacity(0.08),
    shape:   RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    leading: CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white, size: 20)),
    title:   Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    trailing: const Icon(Icons.chevron_right),
  );
}
