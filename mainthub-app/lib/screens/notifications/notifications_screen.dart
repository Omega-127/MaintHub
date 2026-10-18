import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/app_notification.dart';
import '../../providers/auth_provider.dart';
import '../../services/notification_service.dart';
import '../maintanance/pending_screen.dart';
import '../maintanance/due_soon_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = NotificationService();
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL'; // 'ALL', 'OVERDUE', 'REMINDER', 'COMPLETED'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNotificationClick(AppNotification item) async {
    // 1. Mark as read on backend & locally
    if (!item.isRead) {
      setState(() => item.isRead = true);
      _service.markAsRead(item.id);
    }

    final auth = context.read<AuthProvider>();
    final userDept = auth.user?.isAdmin == true ? null : auth.user?.department;

    // 2. Redirect toward overdue machines if overdue
    final isOverdue = item.isOverdue ||
        item.title.toLowerCase().contains('overdue') ||
        item.message.toLowerCase().contains('overdue');
    final isReminder = item.isReminder ||
        item.title.toLowerCase().contains('due') ||
        item.message.toLowerCase().contains('due');

    if (isOverdue) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PendingMaintenanceScreen(department: userDept),
        ),
      );
    } else if (isReminder) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DueSoonScreen(department: userDept),
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    final unread = _notifications.where((n) => !n.isRead).toList();
    if (unread.isEmpty) return;

    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });

    for (final n in unread) {
      _service.markAsRead(n.id);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications marked as read')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _notifications.where((n) {
      if (_selectedFilter == 'OVERDUE') return n.isOverdue;
      if (_selectedFilter == 'REMINDER') return n.isReminder;
      if (_selectedFilter == 'COMPLETED') return n.isCompleted;
      return true;
    }).toList();

    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Filter chips
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('ALL', 'All (${_notifications.length})'),
                        const SizedBox(width: 8),
                        _buildFilterChip('OVERDUE', 'Overdue ⚠️'),
                        const SizedBox(width: 8),
                        _buildFilterChip('REMINDER', 'Due Today 🔔'),
                        const SizedBox(width: 8),
                        _buildFilterChip('COMPLETED', 'Completed ✅'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),

                // Notifications list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: filtered.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.notifications_off_outlined,
                                        size: 64, color: AppTheme.textLight),
                                    SizedBox(height: 16),
                                    Text('No notifications found',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: AppTheme.textLight,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const Divider(height: 1, indent: 72),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return _NotificationTile(
                                item: item,
                                onTap: () => _handleNotificationClick(item),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _selectedFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _selectedFilter = key),
      selectedColor: AppTheme.primary,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppTheme.textDark,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconData = item.isOverdue
        ? Icons.warning_rounded
        : item.isReminder
            ? Icons.schedule_rounded
            : Icons.check_circle_rounded;

    final iconColor = item.isOverdue
        ? AppTheme.danger
        : item.isReminder
            ? AppTheme.warning
            : AppTheme.success;

    final bgColor = iconColor.withValues(alpha: 0.12);

    final dateStr = item.createdAt != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt!)
        : '';

    return Material(
      color: item.isRead ? Colors.white : const Color(0xFFEFF6FF),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 24),
              ),
              const SizedBox(width: 14),

              // Title & Message
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  item.isRead ? FontWeight.w600 : FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        if (!item.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textDark.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textLight,
                          ),
                        ),
                        const Spacer(),
                        if (item.isOverdue)
                          const Row(
                            children: [
                              Text(
                                'View overdue machines',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.danger,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 16, color: AppTheme.danger),
                            ],
                          )
                        else if (item.isReminder)
                          const Row(
                            children: [
                              Text(
                                'View due machines',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  size: 16, color: AppTheme.warning),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
