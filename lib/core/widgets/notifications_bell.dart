import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/notifications/notifications_screen.dart';
import '../data/app_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';
import '../utils/haptics.dart';

/// Bell icon with unread badge. Opens the Fennecly notifications screen
/// where realtime updates arrive in-app.
class NotificationsBell extends StatelessWidget {
  const NotificationsBell({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final unread = store.unreadNotificationsCount;
    final scheme = Theme.of(context).colorScheme;
    final ar = isArabicContext(context);

    return Semantics(
      label: unread > 0
          ? (ar ? 'إشعارات غير مقروءة: $unread' : 'Unread notifications: $unread')
          : (ar ? 'إشعارات' : 'Notifications'),
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          customBorder: const CircleBorder(),
          borderRadius: BorderRadius.circular(999),
          onTap: () {
            AppHaptics.select();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          child: SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  compact ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                  size: AppSizes.iconLg,
                  color: unread > 0 ? scheme.primary : scheme.onSurfaceVariant,
                ),
                if (unread > 0)
                  PositionedDirectional(
                    top: 4,
                    end: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: scheme.error,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: scheme.surfaceContainerLowest,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        unread > 9 ? '9+' : '$unread',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
