import 'package:flutter/material.dart';
import 'package:saber_flutter/app/theme/sahel_colors.dart';
import 'package:saber_flutter/app/theme/sahel_radii.dart';
import 'package:saber_flutter/app/theme/sahel_elevations.dart';

enum SahelButtonVariant {
  filled,
  gradient,
  soft,
  outline,
  ghost,
  danger,
  amber,
}

class SahelButton extends StatelessWidget {
  final SahelButtonVariant variant;
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? prefixIcon;
  final double width;
  final double height;

  SahelButton({
    super.key,
    this.variant = SahelButtonVariant.filled,
    required this.label,
    VoidCallback? onPressed,
    VoidCallback? onTap,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    this.width = double.infinity,
    this.height = 52,
  })  : onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon;

  SahelButton.soft({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 38,
  })  : variant = SahelButtonVariant.soft,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.gradient({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.gradient,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.danger({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.danger,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.amber({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.amber,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.outline({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.outline,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.ghost({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.ghost,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.filled({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.filled,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  SahelButton.whiteBgPrimaryText({
    super.key,
    required String label,
    VoidCallback? onTap,
    VoidCallback? onPressed,
    this.loading = false,
    IconData? prefixIcon,
    IconData? icon,
    Color? bgColor,
    double? width,
    this.height = 52,
  })  : variant = SahelButtonVariant.ghost,
        onPressed = onPressed ?? onTap,
        prefixIcon = prefixIcon ?? icon,
        width = width ?? double.infinity,
        label = label;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || loading;
    final textStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: _textColor,
    );

    return SizedBox(
      width: width,
      height: height,
      child: _buildButton(isDisabled, textStyle),
    );
  }

  Widget _buildButton(bool isDisabled, TextStyle textStyle) {
    switch (variant) {
      case SahelButtonVariant.gradient:
        return _buildGradient(isDisabled, textStyle);
      case SahelButtonVariant.soft:
        return _buildSoft(isDisabled, textStyle);
      case SahelButtonVariant.outline:
        return _buildOutline(isDisabled, textStyle);
      case SahelButtonVariant.ghost:
        return _buildGhost(isDisabled, textStyle);
      case SahelButtonVariant.danger:
        return _buildSolid(isDisabled, textStyle, SahelColors.red600, Colors.white);
      case SahelButtonVariant.amber:
        return _buildSolid(isDisabled, textStyle, SahelColors.amber500, Colors.white);
      case SahelButtonVariant.filled:
        return _buildSolid(isDisabled, textStyle, SahelColors.primary600, Colors.white);
    }
  }

  Color get _textColor {
    switch (variant) {
      case SahelButtonVariant.soft:
        return SahelColors.primary700;
      case SahelButtonVariant.outline:
        return SahelColors.primary700;
      case SahelButtonVariant.ghost:
        return SahelColors.primary700;
      case SahelButtonVariant.danger:
        return Colors.white;
      case SahelButtonVariant.amber:
        return Colors.white;
      case SahelButtonVariant.gradient:
      case SahelButtonVariant.filled:
        return Colors.white;
    }
  }

  Widget _buildContent(TextStyle textStyle) {
    if (loading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: _textColor,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (prefixIcon != null) ...[
          Icon(prefixIcon, size: 18, color: _textColor),
          const SizedBox(width: 8),
        ],
        Text(label, style: textStyle),
      ],
    );
  }

  Widget _buildGradient(bool isDisabled, TextStyle textStyle) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6), Color(0xFF2DD4BF)],
        ),
        borderRadius: BorderRadius.circular(SahelRadii.sm),
        boxShadow: isDisabled ? null : SahelElevations.glow,
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: SahelColors.slate300,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SahelRadii.sm),
          ),
          minimumSize: Size.zero,
        ),
        child: _buildContent(textStyle),
      ),
    );
  }

  Widget _buildSolid(bool isDisabled, TextStyle textStyle, Color bg, Color fg) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDisabled ? SahelColors.slate300 : bg,
        foregroundColor: fg,
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SahelRadii.sm),
        ),
        elevation: 0,
        minimumSize: Size.zero,
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildSoft(bool isDisabled, TextStyle textStyle) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: SahelColors.primary50,
        foregroundColor: SahelColors.primary700,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SahelRadii.sm),
          side: const BorderSide(color: SahelColors.primary100, width: 1),
        ),
        elevation: 0,
        minimumSize: Size.zero,
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildOutline(bool isDisabled, TextStyle textStyle) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: SahelColors.primary700,
        side: const BorderSide(color: SahelColors.primary500, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SahelRadii.sm),
        ),
        minimumSize: Size.zero,
      ),
      child: _buildContent(textStyle),
    );
  }

  Widget _buildGhost(bool isDisabled, TextStyle textStyle) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: SahelColors.primary700,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SahelRadii.sm),
        ),
        minimumSize: Size.zero,
      ),
      child: _buildContent(textStyle),
    );
  }
}

