import 'package:flutter/material.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';

class WorkSection extends StatelessWidget {
  const WorkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHead(
            kicker: 'Selected work',
            title: 'Apps shipped to the stores',
            lead: SheetContent.workLead,
          ),
          for (var i = 0; i < SheetContent.cases.length; i++)
            _CaseStudyView(study: SheetContent.cases[i], first: i == 0),
          const _MoreProjects(),
        ],
      ),
    );
  }
}

class _CaseStudyView extends StatelessWidget {
  const _CaseStudyView({required this.study, required this.first});

  final CaseStudy study;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final pad = Sheet.fluid(width, 40, 5, 64);

    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: p.line)),
      ),
      padding: EdgeInsets.only(top: first ? 0 : pad, bottom: pad),
      child: SheetColumns(
        gap: 48,
        rowGap: 28,
        left: _Rail(items: study.rail),
        right: _CaseBody(study: study),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({required this.items});

  final List<RailItem> items;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final narrow = Sheet.isNarrow(MediaQuery.sizeOf(context).width);

    Widget entry(int i) {
      final item = items[i];
      return Reveal(
        delay: Duration(milliseconds: 70 * i),
        dy: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.label.toUpperCase(),
              style: SheetType.mono(p.muted, 11.2, tracking: 0.1, height: 1.4),
            ),
            const SizedBox(height: 3),
            SegText(
              segs: item.value,
              style: SheetType.body(p.fg, 15.2, height: 1.4),
            ),
          ],
        ),
      );
    }

    if (narrow) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final cell = (box.maxWidth - 16) / 2;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              for (var i = 0; i < items.length; i++)
                SizedBox(width: cell, child: entry(i)),
            ],
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 16),
          entry(i),
        ],
      ],
    );
  }
}

class _CaseBody extends StatelessWidget {
  const _CaseBody({required this.study});

  final CaseStudy study;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Reveal(
          dy: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                header: true,
                child: Text(
                  study.title,
                  style: SheetType.display(
                    p.fg,
                    Sheet.fluid(width, 28.8, 3.2, 41.6),
                    tracking: -0.025,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(study.tagline, style: SheetType.body(p.muted, 18.4)),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Reveal(child: _Facts(facts: study.facts)),
        if (study.pipeline.isNotEmpty) ...<Widget>[
          const SizedBox(height: 28),
          Reveal(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MonoLabel(study.pipelineLabel ?? ''),
                const SizedBox(height: 12),
                _Pipeline(steps: study.pipeline),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),
        _Decisions(items: study.decisions),
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.facts});

  final List<Fact> facts;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final stacked = MediaQuery.sizeOf(context).width <= 560;

    Widget cell(int i) {
      final fact = facts[i];
      return Container(
        padding: EdgeInsets.fromLTRB(
          (!stacked && i > 0) ? 24 : 0,
          18,
          (!stacked && i == 0) ? 24 : 0,
          18,
        ),
        decoration: BoxDecoration(
          border: i == 0
              ? null
              : (stacked
                    ? Border(top: BorderSide(color: p.line))
                    : Border(left: BorderSide(color: p.line))),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              fact.label.toUpperCase(),
              style: SheetType.mono(
                p.accent,
                11.5,
                weight: FontWeight.w500,
                tracking: 0.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(fact.text, style: SheetType.body(p.fg, 16.3)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: p.line)),
      ),
      child: stacked
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (var i = 0; i < facts.length; i++) cell(i),
              ],
            )
          : IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var i = 0; i < facts.length; i++)
                    Expanded(child: cell(i)),
                ],
              ),
            ),
    );
  }
}

/// Five-step build flow. The accent line draws with scroll and lights each
/// step in order, horizontally on wide screens and vertically on narrow ones.
class _Pipeline extends StatelessWidget {
  const _Pipeline({required this.steps});

  final List<PipelineStep> steps;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final vertical = Sheet.isNarrow(MediaQuery.sizeOf(context).width);

    return ScrollWatcher(
      builder: (BuildContext context, double top, double viewport) {
        double progress = 0;
        if (top.isFinite) {
          // Starts when the top edge hits 80% of the viewport, ends when the
          // bottom edge reaches 45%.
          final box = context.findRenderObject();
          final height = box is RenderBox && box.hasSize
              ? box.size.height
              : 0.0;
          final span = viewport * 0.35 + height;
          progress = span <= 0
              ? 0
              : ((viewport * 0.8 - top) / span).clamp(0.0, 1.0);
        }
        if (reduceMotion(context)) {
          progress = 1;
        }
        final lit = (progress * steps.length).round();

        Widget step(int i) => Reveal(
          delay: Duration(milliseconds: 80 * i),
          dy: 20,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: i < lit ? p.accent : p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  steps[i].title,
                  style: SheetType.mono(p.fg, 12.16, weight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(steps[i].caption, style: SheetType.mono(p.muted, 12.16)),
              ],
            ),
          ),
        );

        if (vertical) {
          return Stack(
            children: <Widget>[
              Positioned(
                left: 22,
                top: 0,
                bottom: 0,
                width: 2,
                child: ColoredBox(
                  color: p.line,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: FractionallySizedBox(
                      heightFactor: progress,
                      child: ColoredBox(
                        color: p.accent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var i = 0; i < steps.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: 10),
                    step(i),
                  ],
                ],
              ),
            ],
          );
        }

        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: Align(
                child: SizedBox(
                  height: 2,
                  width: double.infinity,
                  child: ColoredBox(
                    color: p.line,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: ColoredBox(
                          color: p.accent,
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var i = 0; i < steps.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: step(i)),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Decisions extends StatelessWidget {
  const _Decisions({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    const fontSize = 16.3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (var i = 0; i < items.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          Reveal(
            delay: Duration(milliseconds: 70 * i),
            dy: 22,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    left: 0,
                    top: fontSize * 0.72,
                    width: 12,
                    height: 2,
                    child: ColoredBox(color: p.accent),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 26),
                    child: Text(
                      items[i],
                      style: SheetType.body(p.fg, fontSize, height: 1.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MoreProjects extends StatelessWidget {
  const _MoreProjects();

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: Column(
        children: <Widget>[
          for (final project in SheetContent.smallProjects)
            _MoreRow(project: project),
        ],
      ),
    );
  }
}

class _MoreRow extends StatefulWidget {
  const _MoreRow({required this.project});

  final SmallProject project;

  @override
  State<_MoreRow> createState() => _MoreRowState();
}

class _MoreRowState extends State<_MoreRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final project = widget.project;

    return Reveal(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: p.line)),
              ),
              child: SheetColumns(
                gap: 48,
                rowGap: 8,
                left: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      project.title,
                      style: SheetType.display(p.fg, 27.2, tracking: -0.025),
                    ),
                    MonoLabel(project.kind),
                  ],
                ),
                right: SegText(
                  segs: project.description,
                  style: SheetType.body(p.fg, 18),
                  maxWidth: 640,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 2,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: _hover ? 1 : 0),
                duration: reduceMotion(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 450),
                curve: kExpoOut,
                builder: (BuildContext context, double v, Widget? _) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: v,
                      child: ColoredBox(
                        color: p.accent,
                        child: const SizedBox.expand(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
