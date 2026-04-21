import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/constants/app_colors.dart';
import 'package:flutter_portfolio/core/constants/app_radius.dart';
import 'package:flutter_portfolio/core/constants/app_spacing.dart';
import 'package:flutter_portfolio/core/utils/color_utils.dart';
import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/widgets/portfolio_ui_primitives.dart';

Color _wfMuted(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

Color _foregroundFor(Color background) {
  return ThemeData.estimateBrightnessForColor(background) == Brightness.dark
      ? Colors.white
      : AppColors.textLight;
}

/// Premium section: AI tools, workflow pipeline, productivity signals, ethics, CTAs.
class AiWorkflowSection extends StatelessWidget {
  const AiWorkflowSection({
    required this.data,
    required this.onNavigate,
    required this.pipelineAnchorKey,
    super.key,
  });

  final AiWorkflowContent data;
  final ValueChanged<String> onNavigate;
  final GlobalKey pipelineAnchorKey;

  @override
  Widget build(BuildContext context) {
    if (!data.isVisible) {
      return const SizedBox.shrink();
    }
    final width = MediaQuery.sizeOf(context).width;
    final toolColumns = width > 1100
        ? 3
        : width > 720
        ? 2
        : 1;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      container: true,
      label: '${data.sectionLabel}. ${data.sectionTitle}',
      child: Container(
        width: double.infinity,
        color: AppColors.primary.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.02 : 0.06,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
        child: Column(
          children: <Widget>[
            ConstrainedContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _SectionHeader(
                    label: data.sectionLabel,
                    title: data.sectionTitle,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _WorkflowHero(
                    hero: data.hero,
                    onNavigate: onNavigate,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Tools I use',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = AppSpacing.lg;
                      final totalSpacing = spacing * (toolColumns - 1);
                      final itemWidth =
                          (constraints.maxWidth - totalSpacing) / toolColumns;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: data.tools
                            .map(
                              (tool) => SizedBox(
                                width: itemWidth,
                                child: _AiToolCard(item: tool),
                              ),
                            )
                            .toList(growable: false),
                      );
                    },
                  ),
                  SizedBox(height: AppSpacing.xxl + 8),
                  KeyedSubtree(
                    key: pipelineAnchorKey,
                    child: Semantics(
                      header: true,
                      child: const Text(
                        'My real workflow',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Text(
                    'Claude co-works and AI pair programming sit alongside manual review—acceleration without autopilot.',
                    style: TextStyle(height: 1.65, fontSize: 15),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PipelineList(pipeline: data.pipeline),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Productivity signals',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _ProductivitySignals(
                    signals: data.productivitySignals,
                    reduceMotion: reduceMotion,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Why this matters for hiring teams',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BulletPanel(bullets: data.recruiterBullets),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Real use cases',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _UseCasesGrid(useCases: data.useCases),
                  const SizedBox(height: AppSpacing.xxl),
                  _EthicsPanel(
                    headline: data.ethicsHeadline,
                    points: data.ethicsPoints,
                    attribution: data.portfolioAttribution,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Semantics(
                    header: true,
                    child: const Text(
                      'Future-ready',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BadgeStrip(badges: data.badges),
                  const SizedBox(height: AppSpacing.xxl),
                  _CtaBanner(
                    cta: data.cta,
                    onPrimary: () => onNavigate('contact'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.title});

  final String label;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 32,
              height: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[AppColors.primary, AppColors.accent1],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 48,
            height: 1.05,
          ),
        ),
      ],
    );
  }
}

class _WorkflowHero extends StatelessWidget {
  const _WorkflowHero({required this.hero, required this.onNavigate});

  final AiWorkflowHeroContent hero;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GradientText(
                    hero.title,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hero.subtitle,
            style: TextStyle(
              color: _wfMuted(context),
              fontSize: 17,
              height: 1.75,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: hero.ctas
                .map(
                  (c) => GradientButton(
                    label: c.label,
                    onTap: () => onNavigate(c.target),
                    secondary: c.target == 'projects',
                    ghost: c.target == 'workflow-pipeline',
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _AiToolCard extends StatelessWidget {
  const _AiToolCard({required this.item});

  final AiToolItem item;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(item.color);
    final monogramFg = _foregroundFor(color);
    return GlassCard(
      hover: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    colors: <Color>[
                      color,
                      color.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                child: Text(
                  item.monogram,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: monogramFg,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      item.category,
                      style: TextStyle(
                        color: _wfMuted(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.primaryPurpose,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            item.usage,
            style: TextStyle(
              color: _wfMuted(context),
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(color: color.withValues(alpha: 0.45)),
              ),
              child: Text(
                item.impactTag,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineList extends StatelessWidget {
  const _PipelineList({required this.pipeline});

  final List<AiPipelineStageItem> pipeline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: pipeline.asMap().entries.map((entry) {
        final i = entry.key;
        final stage = entry.value;
        final isLast = i == pipeline.length - 1;
        return _PipelineRow(
          index: i + 1,
          stage: stage,
          showConnector: !isLast,
        );
      }).toList(growable: false),
    );
  }
}

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({
    required this.index,
    required this.stage,
    required this.showConnector,
  });

  final int index;
  final AiPipelineStageItem stage;
  final bool showConnector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: <Color>[AppColors.primary, AppColors.accent1],
                  ),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (showConnector)
                Container(
                  width: 2,
                  height: 48,
                  margin: const EdgeInsets.only(top: 6),
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    stage.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    stage.description,
                    style: TextStyle(
                      color: _wfMuted(context),
                      height: 1.6,
                    ),
                  ),
                  if (stage.tools.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: stage.tools
                          .map(
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.full,
                                ),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant,
                                ),
                              ),
                              child: Text(
                                t,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductivitySignals extends StatelessWidget {
  const _ProductivitySignals({
    required this.signals,
    required this.reduceMotion,
  });

  final List<AiProductivitySignalItem> signals;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 980
        ? 4
        : width > 600
        ? 2
        : 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.lg;
        final itemWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: signals
              .map(
                (s) => SizedBox(
                  width: itemWidth,
                  child: _SignalCard(signal: s, reduceMotion: reduceMotion),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal, required this.reduceMotion});

  final AiProductivitySignalItem signal;
  final bool reduceMotion;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(signal.color);
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (signal.displayText != null)
            Text(
              signal.displayText!,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 32,
                color: color,
              ),
            )
          else if (reduceMotion)
            Text(
              '${signal.numericValue ?? 0}${signal.suffix}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 32,
                color: color,
              ),
            )
          else
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1100),
              tween: Tween<double>(
                begin: 0,
                end: (signal.numericValue ?? 0).toDouble(),
              ),
              builder: (context, value, _) {
                return Text(
                  '${value.round()}${signal.suffix}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    color: color,
                  ),
                );
              },
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            signal.label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            signal.subtitle,
            style: TextStyle(
              color: _wfMuted(context),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPanel extends StatelessWidget {
  const _BulletPanel({required this.bullets});

  final List<String> bullets;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: bullets
            .map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('✓ ', style: TextStyle(color: AppColors.primary)),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          color: _wfMuted(context),
                          height: 1.65,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _UseCasesGrid extends StatelessWidget {
  const _UseCasesGrid({required this.useCases});

  final List<AiUseCaseItem> useCases;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width > 1000 ? 2 : 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppSpacing.lg;
        final itemWidth =
            (constraints.maxWidth - spacing * (cols - 1)) / cols;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: useCases
              .map(
                (u) => SizedBox(
                  width: itemWidth,
                  child: GlassCard(
                    hover: true,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          u.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _UseCaseLine(label: 'Problem', text: u.problem),
                        const SizedBox(height: AppSpacing.xs),
                        _UseCaseLine(label: 'Action', text: u.action),
                        const SizedBox(height: AppSpacing.xs),
                        _UseCaseLine(label: 'Outcome', text: u.outcome),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}

class _UseCaseLine extends StatelessWidget {
  const _UseCaseLine({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return RichText(
      text: TextSpan(
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.72),
          height: 1.55,
          fontSize: 13,
        ),
        children: <TextSpan>[
          TextSpan(
            text: '$label: ',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: text),
        ],
      ),
    );
  }
}

class _EthicsPanel extends StatelessWidget {
  const _EthicsPanel({
    required this.headline,
    required this.points,
    required this.attribution,
  });

  final String headline;
  final List<String> points;
  final String attribution;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            headline,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...points.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text('• ', style: TextStyle(color: AppColors.accent1)),
                  Expanded(
                    child: Text(
                      p,
                      style: TextStyle(
                        color: _wfMuted(context),
                        height: 1.65,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            attribution,
            style: TextStyle(
              color: _wfMuted(context).withValues(alpha: 0.95),
              fontSize: 13,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStrip extends StatelessWidget {
  const _BadgeStrip({required this.badges});

  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: badges
          .map(
            (b) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.full),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.35),
                ),
                gradient: LinearGradient(
                  colors: <Color>[
                    AppColors.primary.withValues(alpha: 0.12),
                    AppColors.accent1.withValues(alpha: 0.08),
                  ],
                ),
              ),
              child: Text(
                b,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _CtaBanner extends StatelessWidget {
  const _CtaBanner({required this.cta, required this.onPrimary});

  final AiWorkflowCtaContent cta;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width > 720;
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          cta.headline,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...cta.lines.map(
          (line) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: TextStyle(
                color: _wfMuted(context),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
    return GlassCard(
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(child: body),
                const SizedBox(width: AppSpacing.lg),
                GradientButton(label: cta.primaryButtonLabel, onTap: onPrimary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                body,
                const SizedBox(height: AppSpacing.lg),
                GradientButton(label: cta.primaryButtonLabel, onTap: onPrimary),
              ],
            ),
    );
  }
}
