import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/layout/breakpoints.dart';
import 'package:flutter_portfolio/core/layout/content_width_scope.dart';
import 'package:flutter_portfolio/core/constants/app_colors.dart';
import 'package:flutter_portfolio/core/constants/app_radius.dart';
import 'package:flutter_portfolio/core/constants/app_spacing.dart';

class AppContainer extends StatelessWidget {
  const AppContainer({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: SizedBox.shrink(),
        ),
      ),
    );
  }
}

class ConstrainedContent extends StatelessWidget {
  const ConstrainedContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final horizontal = Breakpoints.contentHorizontalPadding(
      MediaQuery.sizeOf(context).width,
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return ContentWidthScope(
                width: w,
                child: SizedBox(width: w, child: child),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.style,
    this.from = AppColors.primary,
    this.to = AppColors.accent1,
  });

  final String text;
  final TextStyle style;
  final Color from;
  final Color to;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return LinearGradient(colors: [from, to]).createShader(bounds);
      },
      child: Text(text, style: style),
    );
  }
}

class GlassCard extends StatefulWidget {
  const GlassCard({
    required this.child,
    super.key,
    this.onTap,
    this.hover = false,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool hover;
  final EdgeInsets padding;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : colorScheme.surface.withValues(alpha: 0.88);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : colorScheme.outlineVariant.withValues(alpha: 0.7);
    final idleShadowColor = isDark
        ? Colors.black.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.08);
    final child = AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      transform: widget.hover && _hovered
          ? Matrix4.translationValues(0, -6, 0)
          : null,
      padding: widget.padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: borderColor),
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: widget.hover && _hovered
                ? AppColors.primary.withValues(alpha: 0.25)
                : idleShadowColor,
            blurRadius: widget.hover && _hovered ? 60 : 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.onTap == null
          ? child
          : GestureDetector(onTap: widget.onTap, child: child),
    );
  }
}

class GradientButton extends StatefulWidget {
  const GradientButton({
    required this.label,
    super.key,
    this.onTap,
    this.secondary = false,
    this.ghost = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool secondary;
  final bool ghost;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.ghost
        ? BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.16)
                  : colorScheme.outlineVariant.withValues(alpha: 0.9),
            ),
          )
        : widget.secondary
        ? BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          )
        : BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.full),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.accent1],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          );
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          transform: _hovered ? Matrix4.translationValues(0, -2, 0) : null,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
          decoration: base,
          child: Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: widget.secondary
                  ? AppColors.primary
                  : (widget.ghost
                        ? colorScheme.onSurfaceVariant
                        : Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
