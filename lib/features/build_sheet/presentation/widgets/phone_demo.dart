import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';

const Color _kCard = Color(0xFFFFFFFF);
const Color _kOn = Color(0xFFFFFFFF);

/// Colours of the demo screen, interpolated when the flavour changes.
@immutable
class _ScreenColors {
  const _ScreenColors(this.bg, this.fg, this.primary, this.soft);

  factory _ScreenColors.of(DemoFlavour f) =>
      _ScreenColors(f.bg, f.fg, f.primary, f.soft);

  final Color bg;
  final Color fg;
  final Color primary;
  final Color soft;

  static _ScreenColors lerp(_ScreenColors a, _ScreenColors b, double t) {
    return _ScreenColors(
      Color.lerp(a.bg, b.bg, t)!,
      Color.lerp(a.fg, b.fg, t)!,
      Color.lerp(a.primary, b.primary, t)!,
      Color.lerp(a.soft, b.soft, t)!,
    );
  }
}

/// The hero stage: a rotated phone running a fictional college app, a flavour
/// switcher, a build manifest, and a stamp. One codebase, three flavours.
class PhoneDemo extends StatefulWidget {
  const PhoneDemo({required this.intro, super.key});

  final Animation<double> intro;

  @override
  State<PhoneDemo> createState() => _PhoneDemoState();
}

class _PhoneDemoState extends State<PhoneDemo> with TickerProviderStateMixin {
  static const List<DemoFlavour> _flavours = SheetContent.flavours;

  late final AnimationController _colors = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
    value: 1,
  );
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 180),
    value: 1,
  );
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  int _selected = 0;
  int _shown = 0;
  _ScreenColors _from = _ScreenColors.of(_flavours.first);
  _ScreenColors _to = _ScreenColors.of(_flavours.first);
  bool _userPicked = false;
  Timer? _demoTimer;
  int _demoStep = 0;
  bool _demoStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_demoStarted) {
      return;
    }
    _demoStarted = true;
    if (!reduceMotion(context)) {
      // One short tour of the flavours once the intro has settled.
      _demoTimer = Timer(const Duration(milliseconds: 3200), _tourNext);
    }
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _colors.dispose();
    _fade.dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _tourNext() {
    const sequence = <int>[1, 2, 0];
    if (!mounted || _userPicked || _demoStep >= sequence.length) {
      return;
    }
    _select(sequence[_demoStep++]);
    _demoTimer = Timer(const Duration(milliseconds: 1400), _tourNext);
  }

  Future<void> _select(int index) async {
    if (index == _selected) {
      return;
    }
    final previous = _ScreenColors.lerp(_from, _to, _colors.value);
    setState(() {
      _selected = index;
      _from = previous;
      _to = _ScreenColors.of(_flavours[index]);
    });
    if (reduceMotion(context)) {
      setState(() => _shown = index);
      _colors.value = 1;
      return;
    }
    unawaited(_colors.forward(from: 0));
    unawaited(_bounce.forward(from: 0));
    await _fade.reverse();
    if (!mounted) {
      return;
    }
    setState(() => _shown = _selected);
    unawaited(_fade.forward());
  }

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final phoneWidth = math.min(276.0, screenWidth * 0.78);
    final flavour = _flavours[_shown];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildPhone(context, p, phoneWidth, flavour),
        const SizedBox(height: 16),
        IntroFade(
          intro: widget.intro,
          start: 1.1,
          dur: 0.6,
          dy: 0,
          child: Transform.rotate(angle: -6 * math.pi / 180, child: _stamp(p)),
        ),
        const SizedBox(height: 22),
        IntroFade(
          intro: widget.intro,
          start: 0.9,
          dur: 0.7,
          dy: 16,
          child: _switcher(p),
        ),
        const SizedBox(height: 22),
        IntroFade(
          intro: widget.intro,
          start: 0.98,
          dur: 0.7,
          dy: 16,
          child: _manifest(p, flavour),
        ),
        const SizedBox(height: 22),
        IntroFade(
          intro: widget.intro,
          start: 1.06,
          dur: 0.7,
          dy: 16,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Text(
              SheetContent.demoNote,
              textAlign: TextAlign.center,
              style: SheetType.body(p.muted, 13.1, height: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhone(
    BuildContext context,
    SheetPalette p,
    double width,
    DemoFlavour flavour,
  ) {
    final height = width * 19.5 / 9;
    final phone = SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned(
            right: -3,
            top: height * 0.22,
            width: 3,
            height: height * 0.11,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF2C3138),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(2),
                ),
              ),
            ),
          ),
          Positioned(
            right: -3,
            top: height * 0.36,
            width: 3,
            height: height * 0.07,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF2C3138),
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(2),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0D10),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: const Color(0xFF2C3138), width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 90,
                    spreadRadius: -40,
                    offset: const Offset(0, 50),
                  ),
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 40,
                    spreadRadius: -24,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.noScaling),
                  child: AnimatedBuilder(
                    animation: Listenable.merge(<Listenable>[_colors, _fade]),
                    builder: (BuildContext context, Widget? _) {
                      final colors = _ScreenColors.lerp(
                        _from,
                        _to,
                        _colors.value,
                      );
                      return _Screen(
                        colors: colors,
                        flavour: flavour,
                        fade: _fade.value,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 92,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      image: true,
      label:
          'Demo college app screen. Its theme, modules and content change when you pick a flavour below.',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable>[widget.intro, _bounce]),
          child: phone,
          builder: (BuildContext context, Widget? child) {
            final t = kExpoOut.transform(
              introSeg(widget.intro.value, 0.3, 1.4),
            );
            final b = _bounce.value;
            // Wobble on flavour change: -3° -> -1.5° -> -3° with a springy return.
            final double wobble = b < 0.25
                ? Curves.easeOut.transform(b / 0.25) * 1.5
                : 1.5 * (1 - Curves.elasticOut.transform((b - 0.25) / 0.75));
            final double scale = b < 0.25
                ? 1 + 0.015 * Curves.easeOut.transform(b / 0.25)
                : 1 + 0.015 * (1 - Curves.easeOut.transform((b - 0.25) / 0.75));
            final angle = (-3 - 7 * (1 - t) + wobble) * math.pi / 180;
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 80 * (1 - t)),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(scale: scale, child: child),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _stamp(SheetPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: p.bg,
        border: Border.all(color: p.accent, width: 1.5),
      ),
      child: Text(
        SheetContent.stamp.toUpperCase(),
        style: SheetType.mono(p.accent, 11.5, tracking: 0.12),
      ),
    );
  }

  Widget _switcher(SheetPalette p) {
    return Semantics(
      container: true,
      label: 'Choose a demo flavour',
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (var i = 0; i < _flavours.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 4),
                _switchButton(p, i),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _switchButton(SheetPalette p, int i) {
    final f = _flavours[i];
    final on = i == _selected;
    return Pressable(
      radius: 20,
      label: f.label,
      onTap: () {
        _userPicked = true;
        _demoTimer?.cancel();
        _select(i);
      },
      builder: (BuildContext context, bool hovered) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 40, minWidth: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on ? p.fg : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: f.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                f.label,
                style: SheetType.body(
                  on ? p.bg : (hovered ? p.fg : p.muted),
                  14.1,
                  height: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _manifest(SheetPalette p, DemoFlavour f) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: p.line),
        ),
        child: TweenAnimationBuilder<Color?>(
          key: ValueKey<String>(f.id),
          tween: ColorTween(
            begin: f.id == 'a'
                ? p.accent.withValues(alpha: 0)
                : p.accent.withValues(alpha: 0.35),
            end: p.accent.withValues(alpha: 0),
          ),
          duration: const Duration(milliseconds: 800),
          builder: (BuildContext context, Color? flash, Widget? _) {
            final base = SheetType.mono(p.muted, 12.16, height: 1.75);
            final strong = base.copyWith(color: p.fg, backgroundColor: flash);
            return Text.rich(
              TextSpan(
                style: base,
                children: <InlineSpan>[
                  const TextSpan(text: 'flavour: '),
                  TextSpan(text: f.flavourName, style: strong),
                  const TextSpan(text: '\npackage_id: '),
                  TextSpan(text: f.packageId, style: strong),
                  const TextSpan(text: '\nmodules: '),
                  TextSpan(text: f.modules, style: strong),
                  const TextSpan(text: '\ncodebase: '),
                  TextSpan(
                    text: '1',
                    style: base.copyWith(color: p.fg),
                  ),
                  const TextSpan(text: ' · release: '),
                  TextSpan(
                    text: 'codemagic',
                    style: base.copyWith(color: p.fg),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

TextStyle _screenText(
  Color color,
  double size, {
  FontWeight weight = FontWeight.w400,
}) => SheetType.body(color, size, weight: weight, height: 1.3);

/// The app UI drawn inside the phone.
class _Screen extends StatelessWidget {
  const _Screen({
    required this.colors,
    required this.flavour,
    required this.fade,
  });

  final _ScreenColors colors;
  final DemoFlavour flavour;
  final double fade;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final f = flavour;
    Widget swap(Widget child) => Opacity(
      opacity: fade.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(0, (1 - fade) * 10),
        child: child,
      ),
    );

    return Container(
      color: c.bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _status(c),
          swap(_top(c, f)),
          Expanded(
            child: ClipRect(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
                child: swap(_body(c, f)),
              ),
            ),
          ),
          swap(_nav(c, f)),
          Container(
            height: 22,
            color: _kCard,
            alignment: Alignment.center,
            child: Container(
              width: 110,
              height: 4,
              decoration: BoxDecoration(
                color: c.fg.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _status(_ScreenColors c) {
    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 16, 26, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '9:41',
              style: _screenText(c.fg, 11.5, weight: FontWeight.w600),
            ),
            Row(
              children: <Widget>[
                CustomPaint(
                  size: const Size(18, 10),
                  painter: _SignalPainter(c.fg),
                ),
                const SizedBox(width: 5),
                CustomPaint(
                  size: const Size(24, 10),
                  painter: _BatteryPainter(c.fg),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _top(_ScreenColors c, DemoFlavour f) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              f.crest,
              style: _screenText(
                _kOn,
                10.5,
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: 0.2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  f.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _screenText(c.fg, 13.7, weight: FontWeight.w700),
                ),
                Text(
                  'Student app',
                  style: _screenText(
                    c.fg.withValues(alpha: 0.6),
                    10.9,
                    weight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: _kCard,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 15,
              color: c.fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(_ScreenColors c, DemoFlavour f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: f.liveSoon
                          ? _kOn.withValues(alpha: 0.8)
                          : const Color(0xFFFF6B6B),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    f.liveTag.toUpperCase(),
                    style: _screenText(
                      _kOn.withValues(alpha: 0.85),
                      9.6,
                    ).copyWith(letterSpacing: 0.96),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                f.liveTitle,
                style: _screenText(_kOn, 15.2, weight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                f.liveMeta,
                style: _screenText(_kOn.withValues(alpha: 0.85), 11.5),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _kOn,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  f.liveCta,
                  style: _screenText(c.primary, 11.2, weight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            for (var i = 0; i < f.tiles.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _kCard,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: c.soft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        f.tiles[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _screenText(c.fg, 11.5, weight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: <Widget>[
              for (var i = 0; i < f.list.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: i == 0
                        ? null
                        : const Border(
                            top: BorderSide(color: Color(0x0F000000)),
                          ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          f.list[i].$1,
                          overflow: TextOverflow.ellipsis,
                          style: _screenText(c.fg, 11.5),
                        ),
                      ),
                      Text(
                        f.list[i].$2,
                        style: _screenText(c.fg.withValues(alpha: 0.55), 11.5),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _nav(_ScreenColors c, DemoFlavour f) {
    return Container(
      color: _kCard,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      child: Row(
        children: <Widget>[
          for (var i = 0; i < f.nav.length; i++)
            Expanded(
              child: Opacity(
                opacity: i == 0 ? 1 : 0.5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 18,
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == 0 ? c.primary : c.fg,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      f.nav[i],
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      softWrap: false,
                      style: _screenText(
                        i == 0 ? c.primary : c.fg,
                        9.9,
                        weight: i == 0 ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SignalPainter extends CustomPainter {
  const _SignalPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const heights = <double>[4, 6, 8, 10];
    for (var i = 0; i < heights.length; i++) {
      final h = heights[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * 5.0, size.height - h, 3, h),
          const Radius.circular(1),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SignalPainter old) => old.color != color;
}

class _BatteryPainter extends CustomPainter {
  const _BatteryPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final fill = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0.5, 0.5, 20, 9),
        const Radius.circular(2.5),
      ),
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(2, 2, 15, 6),
        const Radius.circular(1.5),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(21.5, 3, 2, 4),
        const Radius.circular(1),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(_BatteryPainter old) => old.color != color;
}
