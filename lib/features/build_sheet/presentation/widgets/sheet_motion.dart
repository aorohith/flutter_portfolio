import 'package:flutter/material.dart';

/// `expo.out`-like easing used across the reveal animations.
const Curve kExpoOut = Cubic(0.16, 1, 0.3, 1);

/// Total length of the hero intro timeline, in seconds.
const double kIntroSeconds = 3.2;

/// Progress (0..1) of a segment that starts at [startSec] and lasts [durSec]
/// inside the intro timeline.
double introSeg(double t, double startSec, double durSec) =>
    (((t * kIntroSeconds) - startSec) / durSec).clamp(0.0, 1.0);

bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fades and lifts [child] while the hero intro timeline plays.
class IntroFade extends StatelessWidget {
  const IntroFade({
    required this.intro,
    required this.start,
    required this.child,
    this.dur = 0.9,
    this.dy = 24,
    super.key,
  });

  final Animation<double> intro;
  final double start;
  final double dur;
  final double dy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: intro,
      child: child,
      builder: (BuildContext context, Widget? child) {
        final v = kExpoOut.transform(introSeg(intro.value, start, dur));
        if (v >= 1) {
          return child!;
        }
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, (1 - v) * dy),
            child: child,
          ),
        );
      },
    );
  }
}

/// Reveals [child] once, the first time it scrolls into the lower part of the
/// viewport. Falls back to visible when there is no scrollable or the user
/// prefers reduced motion.
class Reveal extends StatefulWidget {
  const Reveal({
    required this.child,
    this.delay = Duration.zero,
    this.dy = 28,
    this.threshold = 0.9,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final double dy;

  /// Fraction of the viewport height the top edge must pass.
  final double threshold;

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> {
  ScrollPosition? _position;
  bool _triggered = false;
  bool _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_check);
      _position = next;
      _position?.addListener(_check);
    }
    if (_position == null || reduceMotion(context)) {
      _trigger(immediate: true);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_triggered || !mounted) {
      return;
    }
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) {
      return;
    }
    final top = box.localToGlobal(Offset.zero).dy;
    final viewport = MediaQuery.sizeOf(context).height;
    if (top <= viewport * widget.threshold) {
      _trigger();
    }
  }

  void _trigger({bool immediate = false}) {
    if (_triggered) {
      return;
    }
    _triggered = true;
    if (immediate) {
      _shown = true;
      return;
    }
    if (widget.delay == Duration.zero) {
      setState(() => _shown = true);
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _shown = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_triggered) {
      // Covers first layout and window resizes, where no scroll event fires.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _triggered) {
          return;
        }
        _check();
      });
    }
    if (reduceMotion(context) || _position == null) {
      return widget.child;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: _shown ? 1 : 0),
      duration: const Duration(milliseconds: 900),
      curve: kExpoOut,
      child: widget.child,
      builder: (BuildContext context, double v, Widget? child) {
        if (v >= 1) {
          return child!;
        }
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - v) * widget.dy),
            child: child,
          ),
        );
      },
    );
  }
}

/// Rebuilds [builder] whenever the nearest scrollable moves, passing the
/// widget's top edge and the viewport height.
class ScrollWatcher extends StatefulWidget {
  const ScrollWatcher({required this.builder, super.key});

  final Widget Function(BuildContext context, double top, double viewport)
  builder;

  @override
  State<ScrollWatcher> createState() => _ScrollWatcherState();
}

class _ScrollWatcherState extends State<ScrollWatcher> {
  ScrollPosition? _position;
  double _top = double.infinity;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_update);
      _position = next;
      _position?.addListener(_update);
    }
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    super.dispose();
  }

  void _update() {
    final box = context.findRenderObject();
    if (!mounted || box is! RenderBox || !box.attached || !box.hasSize) {
      return;
    }
    final top = box.localToGlobal(Offset.zero).dy;
    if ((top - _top).abs() > 0.5) {
      setState(() => _top = top);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _top == double.infinity) {
        _update();
      }
    });
    return widget.builder(context, _top, MediaQuery.sizeOf(context).height);
  }
}

/// Counts a number up from zero while the intro timeline plays.
class IntroCount extends StatelessWidget {
  const IntroCount({
    required this.intro,
    required this.end,
    required this.suffix,
    required this.style,
    super.key,
  });

  final Animation<double> intro;
  final int end;
  final String suffix;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: intro,
      builder: (BuildContext context, Widget? _) {
        final v = Curves.easeOutCubic.transform(
          introSeg(intro.value, 0.7, 1.6),
        );
        return Text('${(end * v).round()}$suffix', style: style);
      },
    );
  }
}
