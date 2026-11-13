import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/data/app_store.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/fennecly_notification.dart';
import '../../core/services/fennecly_data_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/soft_card.dart';

/// Fennecly notifications â€” realtime feed shared with the web app.
/// Mirrors dashboard.notifications.index.tsx: list, mark-read, delete.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reload();
    });
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    final store = context.read<AppStore>();
    final rows = await FenneclyDataService.listNotifications();
    if (!mounted) return;
    store.setNotifications(rows);
    setState(() => _loading = false);
  }

  Future<void> _markRead(FenneclyNotification notification) async {
    AppHaptics.select();
    final store = context.read<AppStore>();
    store.markNotificationReadLocal(notification.id, read: true);
    await FenneclyDataService.markNotificationRead(notification.id);
  }

  Future<void> _markAllRead() async {
    AppHaptics.select();
    final store = context.read<AppStore>();
    store.markAllNotificationsReadLocal();
    await FenneclyDataService.markAllNotificationsRead();
    if (!mounted) return;
    final ar = isArabicContext(context);
    showAppSnackBar(
      context,
      ar ? 'ØªÙ… ØªØ­Ø¯ÙŠØ¯ Ø§Ù„ÙƒÙ„ ÙƒÙ…Ù‚Ø±ÙˆØ¡' : 'All notifications marked as read',
    );
  }

  Future<void> _delete(FenneclyNotification notification) async {
    AppHaptics.select();
    final store = context.read<AppStore>();
    store.deleteNotificationLocal(notification.id);
    await FenneclyDataService.deleteNotification(notification.id);
  }

  Future<void> _refresh() async {
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l10n = AppLocalizations.of(context);
    final ar = isArabicContext(context);
    final items = store.notifications;
    final unread = store.unreadNotificationsCount;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(ar ? 'Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª' : 'Notifications'),
        actions: [
          if (unread > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(
                ar ? 'ØªØ­Ø¯ÙŠØ¯ Ø§Ù„ÙƒÙ„' : 'Mark all read',
              ),
            ),
        ],
      ),
      body: AppBackdrop(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _refresh,
                child: items.isEmpty
                    ? CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: EmptyState(
                              icon: Icons.notifications_none_rounded,
                              title: ar
                                  ? 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ø¨Ø¹Ø¯'
                                  : 'No notifications yet',
                              body: ar
                                  ? 'Ø³ØªØ¸Ù‡Ø± Ø¥Ø´Ø¹Ø§Ø±Ø§Øª Ù…ØªØ¬Ø±Ùƒ Ù‡Ù†Ø§ Ø¹Ù†Ø¯ ÙˆØµÙˆÙ„Ù‡Ø§.'
                                  :
                                  'Store notifications land here as they arrive: new orders, return requests, stock alerts.',
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          AppSpacing.lg,
                          AppSpacing.sm,
                          AppSpacing.lg,
                          AppSpacing.bottomNavClearance,
                        ),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return _NotificationCard(
                            item: item,
                            onMarkRead: () => _markRead(item),
                            onDelete: () => _delete(item),
                          );
                        },
                      ),
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.onMarkRead,
    required this.onDelete,
  });

  final FenneclyNotification item;
  final VoidCallback onMarkRead;
  final VoidCallback onDelete;

  IconData get _icon {
    switch (item.type) {
      case 'success':
        return Icons.check_circle_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      case 'stock':
        return Icons.warning_amber_rounded;
      case 'order':
        return Icons.receipt_long_rounded;
      case 'return':
        return Icons.assignment_return_rounded;
      case 'info':
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _foreground(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (item.type) {
      case 'success':
        return AppColors.mintDeep;
      case 'error':
        return scheme.error;
      case 'stock':
        return AppColors.amber;
      case 'order':
        return scheme.primary;
      case 'return':
        return AppColors.amber;
      default:
        return scheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = _foreground(context);
    final texts = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: item.read ? null : onMarkRead,
      child: SoftCard(
        radius: 20,
        padding: const EdgeInsetsDirectional.all(AppSpacing.sm + 2),
        color: item.read ? null : scheme.primary.withValues(alpha: 0.06),
        border: !item.read,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: color, size: AppSizes.iconMd),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: texts.titleSmall?.copyWith(
                            fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        relativeDay(context, item.createdAt,
                            AppLocalizations.of(context)),
                        style: texts.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      item.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: texts.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (!item.read) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isArabicContext(context) ? 'Ø¬Ø¯ÙŠØ¯' : 'NEW',
                        style: texts.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: scheme.onSurfaceVariant,
                size: AppSizes.iconSm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
