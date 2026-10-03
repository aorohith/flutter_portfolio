import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';

enum SheetSection {
  top,
  about,
  work,
  capabilities,
  services,
  experience,
  contact,
}

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    required this.onNavigate,
    required this.onToggleTheme,
    super.key,
  });

  final ValueChanged<SheetSection> onNavigate;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final dark = Theme.brightnessOf(context) == Brightness.dark;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: Sheet.gutter(width)),
          decoration: BoxDecoration(
            color: p.bg.withValues(alpha: 0.88),
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Sheet.maxWidth,
                minHeight: Sheet.headerHeight,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _Brand(onTap: () => onNavigate(SheetSection.top)),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          if (width > 640)
                            _NavLink(
                              'About',
                              () => onNavigate(SheetSection.about),
                            ),
                          _NavLink('Work', () => onNavigate(SheetSection.work)),
                          if (width > 640)
                            _NavLink(
                              'Services',
                              () => onNavigate(SheetSection.services),
                            ),
                          if (width > 430)
                            _NavLink(
                              'Experience',
                              () => onNavigate(SheetSection.experience),
                            ),
                          _NavLink(
                            'Contact',
                            () => onNavigate(SheetSection.contact),
                          ),
                          if (width > 640)
                            _NavLink(
                              'Resume',
                              () => openSheetUrl(SheetContent.resume),
                            ),
                          const SizedBox(width: 6),
                          _ThemeButton(dark: dark, onTap: onToggleTheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Pressable(
      onTap: onTap,
      label: 'Rohith A O, back to top',
      builder: (BuildContext context, bool hovered) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: p.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                SheetContent.name,
                style: SheetType.display(
                  hovered ? p.accent : p.fg,
                  18.4,
                  tracking: -0.01,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final compact = MediaQuery.sizeOf(context).width <= 640;
    return Pressable(
      onTap: onTap,
      label: label,
      builder: (BuildContext context, bool hovered) {
        return ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style:
                    SheetType.body(
                      hovered ? p.accent : p.fg,
                      15.2,
                      height: 1.2,
                    ).copyWith(
                      decoration: hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: p.accent,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({required this.dark, required this.onTap});

  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Pressable(
      onTap: onTap,
      radius: 22,
      label: dark ? 'Switch to light theme' : 'Switch to dark theme',
      builder: (BuildContext context, bool hovered) {
        return Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: hovered ? p.fg : p.line),
          ),
          alignment: Alignment.center,
          child: CustomPaint(
            size: const Size(18, 18),
            painter: _HalfMoonPainter(p.fg),
          ),
        );
      },
    );
  }
}

/// Outlined circle with its right half filled: the theme toggle glyph.
class _HalfMoonPainter extends CustomPainter {
  const _HalfMoonPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 1;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -1.5707963,
      3.1415926,
      true,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_HalfMoonPainter old) => old.color != color;
}
