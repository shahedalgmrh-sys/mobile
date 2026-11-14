import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

/// The Sahel lockup: a gradient tile holding the brand glyph next to the
/// Arabic wordmark — identical to the logo used across the web build.
class SahelBrandMark extends StatelessWidget {
  const SahelBrandMark({
    super.key,
    this.size = 32,
    this.showName = true,
    this.nameColor,
  });

  final double size;
  final bool showName;
  final Color? nameColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            color: SahelColors.surface,
            borderRadius: BorderRadius.circular(size * 0.3),
            boxShadow: SahelElevations.xs,
          ),
          child: Image.asset(
            'assets/images/saber-mark.png',
            fit: BoxFit.contain,
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 8),
          Text(
            'سابر',
            style: TextStyle(
              fontSize: size * 0.56,
              fontWeight: FontWeight.w800,
              color: nameColor ?? SahelColors.text,
              letterSpacing: 0,
            ),
          ),
        ],
      ],
    );
  }
}

/// Shared auth-screen header mirroring the Stitch auth shell: a 56px bar with
/// a back affordance on the trailing edge (RTL) followed by the brand lockup.
class SahelAuthHeader extends StatelessWidget {
  const SahelAuthHeader({super.key, this.showBack = true, this.onBack});

  final bool showBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: showBack
          ? Row(
              children: [
                _HeaderIconButton(
                  icon: Icons.arrow_back,
                  onTap: onBack ??
                      () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/login');
                        }
                      },
                ),
                const SizedBox(width: 2),
                const SahelBrandMark(),
                const Spacer(),
              ],
            )
          : const Center(child: SahelBrandMark()),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 22, color: SahelColors.textMuted),
        ),
      ),
    );
  }
}
