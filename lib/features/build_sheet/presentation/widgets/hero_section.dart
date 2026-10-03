import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/phone_demo.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({required this.intro, super.key});

  final Animation<double> intro;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final narrow = Sheet.isNarrow(width);
    final copy = _HeroCopy(intro: intro);
    final stage = PhoneDemo(intro: intro);

    return Padding(
      padding: EdgeInsets.only(
        top: Sheet.fluid(width, 28, 4, 56),
        bottom: Sheet.fluid(width, 56, 7, 96),
      ),
      child: narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                copy,
                const SizedBox(height: 48),
                Center(child: stage),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(flex: 12, child: copy),
                SizedBox(width: Sheet.fluid(width, 32, 6, 80)),
                Expanded(flex: 8, child: stage),
              ],
            ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy({required this.intro});

  final Animation<double> intro;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final nameSize = Sheet.fluid(width, 57.6, 12, 152);
    final ledeSize = Sheet.fluid(width, 19.2, 2.1, 25.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IntroFade(
          intro: intro,
          start: 0.35,
          child: const MonoLabel(SheetContent.kicker),
        ),
        const SizedBox(height: 18),
        _MaskedName(
          intro: intro,
          text: SheetContent.name,
          style: SheetType.display(
            p.fg,
            nameSize,
            weight: FontWeight.w800,
            tracking: -0.045,
            height: 0.92,
          ),
        ),
        const SizedBox(height: 26),
        IntroFade(
          intro: intro,
          start: 0.43,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: ledeSize * 17),
            child: Text(
              SheetContent.lede,
              style: SheetType.body(p.fg, ledeSize, height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 22),
        IntroFade(intro: intro, start: 0.51, child: const AvailabilityRow()),
        const SizedBox(height: 30),
        IntroFade(intro: intro, start: 0.59, child: const ActionRow()),
        const SizedBox(height: 48),
        IntroFade(
          intro: intro,
          start: 0.67,
          child: _Stats(intro: intro),
        ),
      ],
    );
  }
}

/// The name, one glyph at a time rising out of a mask. A [FittedBox] scales
/// it down to stay on one line once the real font has loaded.
class _MaskedName extends StatelessWidget {
  const _MaskedName({
    required this.intro,
    required this.text,
    required this.style,
  });

  final Animation<double> intro;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize ?? 100;
    final lineHeight = size * (style.height ?? 1);

    return Semantics(
      header: true,
      label: text,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: intro,
            builder: (BuildContext context, Widget? _) {
              final glyphs = <Widget>[];
              final chars = text.split('');
              for (var i = 0; i < chars.length; i++) {
                final v = kExpoOut.transform(
                  introSeg(intro.value, 0.1 + i * 0.035, 1.1),
                );
                glyphs.add(
                  ClipRect(
                    clipper: _PadClipper(size * 0.1),
                    child: Transform.translate(
                      offset: Offset(0, (1 - v) * lineHeight * 1.25),
                      child: Text(chars[i], style: style),
                    ),
                  ),
                );
              }
              return Row(mainAxisSize: MainAxisSize.min, children: glyphs);
            },
          ),
        ),
      ),
    );
  }
}

class _PadClipper extends CustomClipper<Rect> {
  const _PadClipper(this.pad);

  final double pad;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(-pad, -pad, size.width + pad, size.height + pad);

  @override
  bool shouldReclip(_PadClipper oldClipper) => oldClipper.pad != pad;
}

class _Stats extends StatelessWidget {
  const _Stats({required this.intro});

  final Animation<double> intro;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final numberSize = Sheet.fluid(width, 32, 4, 44.8);
    final captionSize = width <= 560 ? 12.5 : 13.6;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (var i = 0; i < SheetContent.stats.length; i++)
                Expanded(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(i == 0 ? 0 : 16, 18, 16, 0),
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(left: BorderSide(color: p.line)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        IntroCount(
                          intro: intro,
                          end: SheetContent.stats[i].$1,
                          suffix: SheetContent.stats[i].$2,
                          style:
                              SheetType.display(
                                p.fg,
                                numberSize,
                                tracking: -0.03,
                                height: 1,
                              ).copyWith(
                                fontFeatures: const <FontFeature>[
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          SheetContent.stats[i].$3,
                          style: SheetType.body(
                            p.muted,
                            captionSize,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
