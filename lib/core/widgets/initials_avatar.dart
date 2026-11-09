import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../utils/formatters.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.size = AppSizes.avatar,
    this.onTap,
  });

  final String name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final gradient =
        AppColors.avatarGradients[colorSeedOf(name) %
            AppColors.avatarGradients.length];
    final avatar = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initialsOf(name),
        textDirection: TextDirection.ltr,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.lightSurface,
          fontSize: size * 0.34,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
