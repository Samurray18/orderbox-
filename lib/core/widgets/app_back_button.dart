import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: AppSpacing.xs),
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
        icon: Icon(
          rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
          size: AppSizes.iconLg,
        ),
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHigh.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
