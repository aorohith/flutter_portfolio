import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openSheetUrl(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // Nothing useful to show; the link simply does not open.
  }
}

/// Hover + keyboard-focus aware tap target with the design's focus ring.
class Pressable extends StatefulWidget {
  const Pressable({
    required this.onTap,
    required this.builder,
    this.label,
    this.radius = 4,
    super.key,
  });

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, bool hovered) builder;
  final String? label;
  final double radius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    Widget content = Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        widget.builder(context, _hover),
        if (_focus)
          Positioned(
            left: -6,
            top: -6,
            right: -6,
            bottom: -6,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.radius + 6),
                  border: Border.all(color: p.accent, width: 3),
                ),
              ),
            ),
          ),
      ],
    );
    content = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: content,
    );
    if (widget.label != null) {
      content = Semantics(
        button: true,
        label: widget.label,
        excludeSemantics: true,
        onTap: widget.onTap,
        child: content,
      );
    }
    return FocusableActionDetector(
      enabled: widget.onTap != null,
      mouseCursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onShowHoverHighlight: (bool v) => setState(() => _hover = v),
      onShowFocusHighlight: (bool v) => setState(() => _focus = v),
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (ActivateIntent _) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: content,
    );
  }
}

/// Pill button: outlined, or filled when [primary].
class SheetButton extends StatelessWidget {
  const SheetButton({
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Pressable(
      onTap: onPressed,
      label: label,
      radius: 24,
      builder: (BuildContext context, bool hovered) {
        final Color bg = hovered
            ? p.fg
            : (primary ? p.accent : Colors.transparent);
        final Color border = hovered ? p.fg : (primary ? p.accent : p.fg);
        final Color ink = hovered ? p.bg : (primary ? p.accentInk : p.fg);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: ink),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: SheetType.body(
                  ink,
                  15.2,
                  weight: FontWeight.w500,
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

/// Inline underlined link with the trailing north-east arrow.
class InlineLink extends StatefulWidget {
  const InlineLink({
    required this.text,
    required this.url,
    required this.style,
    super.key,
  });

  final String text;
  final String url;
  final TextStyle style;

  @override
  State<InlineLink> createState() => _InlineLinkState();
}

class _InlineLinkState extends State<InlineLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final color = _hover ? p.accent : widget.style.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        link: true,
        label: widget.text,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => openSheetUrl(widget.url),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: widget.text,
                  style: widget.style.copyWith(
                    color: color,
                    decoration: TextDecoration.underline,
                    decorationColor: p.accent,
                    decorationThickness: 1.6,
                  ),
                ),
                TextSpan(
                  text: '↗',
                  style: widget.style.copyWith(
                    color: color,
                    fontSize: (widget.style.fontSize ?? 16) * 0.8,
                    decoration: TextDecoration.none,
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

/// Paragraph made of plain and link segments.
class SegText extends StatelessWidget {
  const SegText({
    required this.segs,
    required this.style,
    this.maxWidth,
    super.key,
  });

  final List<Seg> segs;
  final TextStyle style;
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final text = Text.rich(
      TextSpan(
        style: style,
        children: <InlineSpan>[
          for (final seg in segs)
            if (seg.url == null)
              TextSpan(text: seg.text)
            else
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: InlineLink(text: seg.text, url: seg.url!, style: style),
              ),
        ],
      ),
    );
    if (maxWidth == null) {
      return text;
    }
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: text,
    );
  }
}

/// Centred, width-capped page column with the fluid side gutter.
class SheetWrap extends StatelessWidget {
  const SheetWrap({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sheet.gutter(width)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Sheet.maxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// Narrow label rail beside a wide column; stacks on small screens.
class SheetColumns extends StatelessWidget {
  const SheetColumns({
    required this.left,
    required this.right,
    this.gap = 48,
    this.rowGap = 16,
    super.key,
  });

  final Widget left;
  final Widget right;
  final double gap;
  final double rowGap;

  @override
  Widget build(BuildContext context) {
    if (Sheet.isNarrow(MediaQuery.sizeOf(context).width)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          left,
          SizedBox(height: rowGap),
          right,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(child: left),
        SizedBox(width: gap),
        Expanded(flex: 3, child: right),
      ],
    );
  }
}

/// Uppercase mono metadata label.
class MonoLabel extends StatelessWidget {
  const MonoLabel(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Text(
      text.toUpperCase(),
      style: SheetType.label(p).copyWith(color: color ?? p.muted),
    );
  }
}

/// Section heading: kicker on the rail, large headline (and lead) beside it.
class SectionHead extends StatelessWidget {
  const SectionHead({
    required this.kicker,
    required this.title,
    this.lead,
    super.key,
  });

  final String kicker;
  final String title;
  final String? lead;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: EdgeInsets.only(bottom: Sheet.fluid(width, 36, 5, 72)),
      child: SheetColumns(
        left: Reveal(child: MonoLabel(kicker)),
        right: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Reveal(
              dy: 40,
              child: Semantics(
                header: true,
                child: Text(
                  title,
                  style: SheetType.display(
                    p.fg,
                    Sheet.fluid(width, 35.2, 5.2, 64),
                    tracking: -0.03,
                  ),
                ),
              ),
            ),
            if (lead != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Reveal(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Text(lead!, style: SheetType.body(p.muted, 16.8)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Section shell: hairline above, fluid vertical padding.
class SheetBlock extends StatelessWidget {
  const SheetBlock({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = Sheet.fluid(width, 64, 9, 128);
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      padding: EdgeInsets.symmetric(vertical: pad),
      width: double.infinity,
      child: child,
    );
  }
}

class AvailabilityRow extends StatelessWidget {
  const AvailabilityRow({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: p.ok,
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(color: p.ok.withValues(alpha: 0.22), spreadRadius: 4),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            SheetContent.availability,
            style: SheetType.body(p.muted, 15.2, height: 1.4),
          ),
        ),
      ],
    );
  }
}

/// Copy-email / GitHub / LinkedIn (/ Resume) buttons with a "Copied" status.
class ActionRow extends StatefulWidget {
  const ActionRow({this.includeResume = false, super.key});

  final bool includeResume;

  @override
  State<ActionRow> createState() => _ActionRowState();
}

class _ActionRowState extends State<ActionRow> {
  String _status = '';
  int _token = 0;

  Future<void> _copy() async {
    final token = ++_token;
    String message;
    try {
      await Clipboard.setData(const ClipboardData(text: SheetContent.email));
      message = 'Copied';
    } catch (_) {
      message = 'Copy failed. Select the address instead.';
    }
    if (!mounted) {
      return;
    }
    setState(() => _status = message);
    await Future<void>.delayed(const Duration(milliseconds: 2500));
    if (mounted && token == _token) {
      setState(() => _status = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        SheetButton(
          label: 'Copy email',
          primary: true,
          icon: Icons.copy_rounded,
          onPressed: _copy,
        ),
        SheetButton(
          label: 'GitHub',
          onPressed: () => openSheetUrl(SheetContent.github),
        ),
        SheetButton(
          label: 'LinkedIn',
          onPressed: () => openSheetUrl(SheetContent.linkedin),
        ),
        if (widget.includeResume)
          SheetButton(
            label: 'Resume (PDF)',
            onPressed: () => openSheetUrl(SheetContent.resume),
          ),
        Semantics(
          liveRegion: true,
          child: Text(_status, style: SheetType.mono(p.accent, 12.8)),
        ),
      ],
    );
  }
}
