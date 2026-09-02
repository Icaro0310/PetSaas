import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme.dart';
import '../../core/services/supabase_service.dart';
import '../../core/utils/formatters.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = SupabaseService.currentUserId;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final data = await SupabaseService.client
          .from('notifications_log')
          .select()
          .eq('user_id', user)
          .order('created_at', ascending: false)
          .limit(100);
      setState(() {
        _items = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markRead(String id) async {
    await SupabaseService.client.from('notifications_log').update({
      'read_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
    _load();
  }

  Future<void> _markAllRead() async {
    final user = SupabaseService.currentUserId;
    if (user == null) return;
    await SupabaseService.client
        .from('notifications_log')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', user)
        .filter('read_at', 'is', null);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificacoes'),
        actions: [
          if (_items.any((n) => n['read_at'] == null))
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllRead,
              tooltip: 'Marcar todas como lidas',
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_none,
                  title: 'Sem notificacoes',
                  subtitle: 'Avisos sobre doses e pets encontrados aparecem aqui.',
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final n = _items[i];
                    final unread = n['read_at'] == null;
                    return ListTile(
                      leading: Icon(
                        _iconFor(n['type'] as String? ?? ''),
                        color: unread ? AppTheme.primary : AppTheme.textMuted,
                      ),
                      title: Text(
                        n['title'] as String? ?? '',
                        style: TextStyle(
                          fontWeight:
                              unread ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((n['body'] as String?)?.isNotEmpty ?? false)
                            Text(n['body'] as String),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.dateTime(
                                DateTime.parse(n['created_at'] as String).toLocal()),
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      trailing: unread
                          ? const Icon(Icons.circle,
                              size: 10, color: AppTheme.accent)
                          : null,
                      onTap: unread ? () => _markRead(n['id'] as String) : null,
                    );
                  },
                ),
    );
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'pet_found':
        return Icons.pets;
      case 'dose_missed':
        return Icons.warning_amber;
      default:
        return Icons.notifications;
    }
  }
}
