import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/data/algeria_wilaya_shapes.dart';
import '../../core/data/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_back_button.dart';
import '../../core/widgets/app_backdrop.dart';
import '../../core/widgets/soft_card.dart';

/// Delivery map â€” Algeria wilayas.
///
/// Visual parity with the web "delivery map" page: wilayas coloured by
/// order volume, distance from the selected origin wilaya, and the
/// synced delivery tariff cache (home / stop desk) per wilaya.
class DeliveryMapScreen extends StatefulWidget {
  const DeliveryMapScreen({super.key});

  @override
  State<DeliveryMapScreen> createState() => _DeliveryMapScreenState();
}

/// Parses the absolute `M ... L ... Z` SVG subset used by the shapes.
Path _buildWilayaPath(String d) {
  final path = Path();
  final token = RegExp(r'([MLZ])([^MLZ]*)');
  for (final m in token.allMatches(d)) {
    final cmd = m.group(1)!;
    if (cmd == 'Z') {
      path.close();
      continue;
    }
    final numbers = (m.group(2) ?? '')
        .split(RegExp(r'[,\s]+'))
        .where((part) => part.trim().isNotEmpty)
        .map((part) => double.tryParse(part))
        .whereType<double>()
        .toList();
    for (var i = 0; i + 1 < numbers.length; i += 2) {
      final x = numbers[i];
      final y = numbers[i + 1];
      if (cmd == 'M') {
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      } else {
        path.lineTo(x, y);
      }
    }
  }
  return path;
}

class _DeliveryMapScreenState extends State<DeliveryMapScreen> {
  late final List<Path> _paths =
      kAlgeriaWilayaShapes.map((shape) => _buildWilayaPath(shape.pathString)).toList();
  int _selected = 16; // Algiers
  int _origin = 16;

  Map<int, int> _orderCounts(AppStore store) {
    final counts = <int, int>{};
    for (final order in store.orders) {
      final code = int.tryParse(order.wilayaCode.replaceAll(RegExp(r'[^0-9]'), ''));
      if (code == null) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }
    return counts;
  }

  double _distanceBetween(int a, int b) {
    if (a == b) return 0;
    final pa = kAlgeriaWilayaShapes[a - 1];
    final pb = kAlgeriaWilayaShapes[b - 1];
    // 1000 map units â‰ˆ 1950 km of longitude span at Algeria's latitude.
    const scale = 1.95;
    final dx = (pa.cx - pb.cx) * scale;
    final dy = (pa.cy - pb.cy) * scale;
    return math.sqrt(dx * dx + dy * dy);
  }

  Future<void> _openInGoogleMaps(String wilayaName) async {
    AppHaptics.select();
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$wilayaName, Algeria')}',
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final ar = isArabicContext(context);
    final scheme = Theme.of(context).colorScheme;
    final counts = _orderCounts(store);
    final selected = kAlgeriaWilayaShapes[_selected - 1];
    final selectedCount = counts[_selected] ?? 0;
    final distanceKm = _distanceBetween(_origin, _selected);


    final wKey = _selected.toString().padLeft(2, '0');
    final home = store.shippingFee(wKey, 'home');
    final office = store.shippingFee(wKey, 'office');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(ar ? 'Ø®Ø±ÙŠØ·Ø© Ø§Ù„ØªÙˆØµÙŠÙ„' : 'Carte des livraisons'),
            Text(
              ar ? 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø­Ø³Ø¨ Ø§Ù„ÙˆÙ„Ø§ÙŠØ©' : 'Commandes par wilaya',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
      body: AppBackdrop(
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapUp: (details) {
                    final size = context.size;
                    if (size == null) return;
                    final hit = _hitTest(details.localPosition, size);
                    if (hit != null && hit != _selected) {
                      AppHaptics.select();
                      setState(() => _selected = hit);
                    }
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _AlgeriaMapPainter(
                        paths: _paths,
                        selected: _selected,
                        counts: counts,
                        primary: AppColors.primary,
                        onSurface: scheme.onSurface,
                        filled: scheme.primary,
                        muted: scheme.surfaceContainerHigh,
                        dark: Theme.of(context).brightness == Brightness.dark,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
              SoftCard(
                margin: const EdgeInsetsDirectional.fromSTEB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  8,
                ),
                padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                radius: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ar ? 'Ø§Ù„ÙˆÙ„Ø§ÙŠØ©' : 'Wilaya',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                selected.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ar ? 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª' : 'Commandes',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                formatNumber(context, selectedCount),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ar ? 'Ø§Ù„Ù…Ø³Ø§ÙØ©' : 'Distance',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                              Text(
                                _origin == _selected
                                    ? 'â€”'
                                    : '${distanceKm.toStringAsFixed(0)} km',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.my_location_rounded,
                            size: 16, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          '${ar ? 'Ù…Ù†' : 'Depuis'}: ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _origin,
                              isExpanded: true,
                              isDense: true,
                              alignment: AlignmentDirectional.centerStart,
                              items: [
                                for (final shape in kAlgeriaWilayaShapes)
                                  DropdownMenuItem(
                                    value: shape.code,
                                    child: Text(
                                      '${shape.code.toString().padLeft(2, '0')} Â· ${shape.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                AppHaptics.select();
                                setState(() => _origin = value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PricePill(
                            icon: Icons.home_rounded,
                            label: ar ? 'Ø¥Ù„Ù‰ Ø§Ù„Ù…Ù†Ø§Ø²Ù„' : 'Livraison domicile',
                            value: formatCurrency(context, home, compact: true),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _PricePill(
                            icon: Icons.store_rounded,
                            label: ar ? 'Ù„Ù„Ù…ÙƒØªØ¨' : 'Stop desk',
                            value: formatCurrency(context, office, compact: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextButton.icon(
                      onPressed: () => _openInGoogleMaps(selected.name),
                      icon: const Icon(Icons.open_in_new_rounded, size: AppSizes.iconSm),
                      label: Text(ar ? 'ÙØªØ­ ÙÙŠ Google Maps' : 'Ouvrir dans Google Maps'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  int? _hitTest(Offset localPosition, Size size) {
    final padding = 4.0;
    final innerWidth = size.width - padding * 2;
    final innerHeight = size.height - padding * 2;
    final scaleX = innerWidth / kAlgeriaMapWidth;
    final scaleY = innerHeight / kAlgeriaMapHeight;
    final scale = math.min(scaleX, scaleY);
    final drawWidth = kAlgeriaMapWidth * scale;
    final drawHeight = kAlgeriaMapHeight * scale;
    final offsetX = (size.width - drawWidth) / 2;
    final offsetY = (size.height - drawHeight) / 2;
    final mapPoint = Offset(
      (localPosition.dx - offsetX) / scale,
      (localPosition.dy - offsetY) / scale,
    );
    for (var i = 0; i < _paths.length; i++) {
      if (_paths[i].contains(mapPoint)) return i + 1;
    }
    return null;
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsetsDirectional.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: AppSizes.iconSm, color: scheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlgeriaMapPainter extends CustomPainter {
  const _AlgeriaMapPainter({
    required this.paths,
    required this.selected,
    required this.counts,
    required this.primary,
    required this.onSurface,
    required this.filled,
    required this.muted,
    required this.dark,
  });

  final List<Path> paths;
  final int selected;
  final Map<int, int> counts;
  final Color primary, onSurface, filled, muted;
  final bool dark;

  Color _bucket(int? count) {
    if (count == null || count <= 0) return muted;
    if (count <= 3) return primary.withValues(alpha: 0.28);
    if (count <= 8) return primary.withValues(alpha: 0.55);
    if (count <= 20) return primary.withValues(alpha: 0.75);
    return primary;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 4.0;
    final scaleX = (size.width - padding * 2) / kAlgeriaMapWidth;
    final scaleY = (size.height - padding * 2) / kAlgeriaMapHeight;
    final scale = math.min(scaleX, scaleY);
    final drawWidth = kAlgeriaMapWidth * scale;
    final drawHeight = kAlgeriaMapHeight * scale;
    final offsetX = (size.width - drawWidth) / 2;
    final offsetY = (size.height - drawHeight) / 2;
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final stroke = Paint()
      ..color = dark ? const Color(0xFF2A2142) : Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final selectedPaint = Paint()
      ..color = filled
      ..style = PaintingStyle.fill;

    for (var i = 0; i < paths.length; i++) {
      final code = i + 1;
      final count = counts[code];
      final path = paths[i];
      if (code == selected) {
        canvas.drawPath(path, selectedPaint);
      } else {
        final paint = Paint()
          ..color = _bucket(count)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, paint);
      }
      canvas.drawPath(path, stroke);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _AlgeriaMapPainter oldDelegate) =>
      oldDelegate.selected != selected || oldDelegate.counts != counts;
}
