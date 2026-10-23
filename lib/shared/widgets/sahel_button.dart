import 'package:flutter/material.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_theme.dart';

enum SahelButtonVariant {
  filled,
  gradient,
  soft,
  outline,
  ghost,
  danger,
  amber,

  /// Solid white surface with brand-teal text — used on top of gradient /
  /// photography heroes where a filled button would lose contrast.
  whiteBg,
}

/// Brand button following the Sahel design system:
/// minimum height `48`, `10.5` radius (pill for [SahelButtonVariant.whiteBg]),
/// weight `700` label, and a `4px` atmospheric focus halo in `#f0fdfa` tints.
class SahelButton extends StatelessWidget {
  final SahelButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? prefixIcon;
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SahelButton({
    super.key,
    this.variant = SahelButtonVariant.filled,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.prefixIcon,
    this.width = double.infinity,
    this.height = 48,
    this.borderRadius,
  });

  factory SahelButton.filled({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.filled,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.gradient({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.gradient,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.soft({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 40,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.soft,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.outline({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.outline,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.ghost({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.ghost,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.danger({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.danger,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.amber({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 48,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.amber,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  factory SahelButton.whiteBgPrimaryText({
    Key? key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    bool loading = false,
    IconData? prefixIcon,
    IconData? icon,
    double? width,
    double height = 40,
  }) =>
      SahelButton(
        key: key,
        variant: SahelButtonVariant.whiteBg,
        label: label,
        onPressed: onPressed ?? onTap,
        loading: loading,
        prefixIcon: prefixIcon ?? icon,
        width: width ?? double.infinity,
        height: height,
      );

  bool get _isDisabled => onPressed == null || loading;

  BorderRadius get _radius =>
      borderRadius ??
      (variant == SahelButtonVariant.whiteBg
          ? SahelRadii.pillRadius
          : SahelRadii.smRadius);

  Color get _foreground {
    if (_isDisabled) {
      switch (variant) {
        case SahelButtonVariant.ghost:
        case SahelButtonVariant.outline:
        case SahelButtonVariant.whiteBg:
          return SahelColors.textSoft;
        default:
          return SahelColors.onPrimary70;
      }
    }
    switch (variant) {
      case SahelButtonVariant.soft:
      case SahelButtonVariant.outline:
      case SahelButtonVariant.ghost:
      case SahelButtonVariant.whiteBg:
        return SahelColors.primary700;
      case SahelButtonVariant.filled:
      case SahelButtonVariant.gradient:
      case SahelButtonVariant.danger:
      case SahelButtonVariant.amber:
        return SahelColors.onPrimary;
    }
  }

  BoxDecoration _decoration() {
    switch (variant) {
      case SahelButtonVariant.gradient:
        return BoxDecoration(
          gradient: _isDisabled ? null : SahelColors.primaryGradient,
          color: _isDisabled ? SahelColors.slate300 : null,
          borderRadius: _radius,
          boxShadow: _isDisabled ? null : SahelElevations.glow,
        );
      case SahelButtonVariant.soft:
        return BoxDecoration(
          color: _isDisabled ? SahelColors.surface3 : SahelColors.primarySurface,
          borderRadius: _radius,
          border: Border.all(
            color: _isDisabled ? SahelColors.border : SahelColors.primary100,
          ),
        );
      case SahelButtonVariant.outline:
        return BoxDecoration(
          color: SahelColors.surface,
          borderRadius: _radius,
          border: Border.all(
            color: _isDisabled ? SahelColors.border : SahelColors.primary,
            width: 1.5,
          ),
        );
      case SahelButtonVariant.ghost:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: _radius,
        );
      case SahelButtonVariant.danger:
        return BoxDecoration(
          color: _isDisabled ? SahelColors.slate300 : SahelColors.red600,
          borderRadius: _radius,
          boxShadow: _isDisabled ? null : SahelElevations.xs,
        );
      case SahelButtonVariant.amber:
        return BoxDecoration(
          color: _isDisabled ? SahelColors.slate300 : SahelColors.amber500,
          borderRadius: _radius,
          boxShadow: _isDisabled ? null : SahelElevations.xs,
        );
      case SahelButtonVariant.whiteBg:
        return BoxDecoration(
          color: SahelColors.surface,
          borderRadius: _radius,
          boxShadow: _isDisabled ? null : SahelElevations.xs,
        );
      case SahelButtonVariant.filled:
        return BoxDecoration(
          color: _isDisabled ? SahelColors.slate300 : SahelColors.primary,
          borderRadius: _radius,
          boxShadow: _isDisabled ? null : SahelElevations.xs,
        );
    }
  }

  Widget _content() {
    if (loading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _foreground,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18, color: _foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _foreground,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: _decoration(),
          child: InkWell(
            onTap: _isDisabled ? null : onPressed,
            borderRadius: _radius,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(child: _content()),
            ),
          ),
        ),
      ),
    );
  }
}
