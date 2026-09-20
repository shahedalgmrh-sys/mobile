import 'package:flutter/material.dart';
import '../theme/sahel_colors.dart';
import 'sahel_button.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: SahelColors.primary300,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: SahelColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: SahelColors.muted,
                height: 1.5,
              ),
            ),
            if (ctaLabel != null) ...[
              const SizedBox(height: 24),
              SahelButton.soft(
                label: ctaLabel!,
                onTap: onCta,
                width: 200,
                height: 48,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

