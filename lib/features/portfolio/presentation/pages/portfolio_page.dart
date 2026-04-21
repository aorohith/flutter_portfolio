import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/constants/app_colors.dart';
import 'package:flutter_portfolio/core/constants/app_radius.dart';
import 'package:flutter_portfolio/core/constants/app_spacing.dart';
import 'package:flutter_portfolio/core/utils/color_utils.dart';
import 'package:flutter_portfolio/core/theme/app_theme.dart';
import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/constants/ai_workflow_content.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/state/portfolio_controller.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/utils/display_stats.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/widgets/ai_workflow_section.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/widgets/portfolio_ui_primitives.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Color _mutedText(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key, this.initialScrollSection});

  /// Optional section id for deep links (`workflow`, `projects`, `contact`, etc.).
  final String? initialScrollSection;

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _workflowPipelineKey = GlobalKey();
  final Map<String, GlobalKey> _sectionKeys = <String, GlobalKey>{
    'home': GlobalKey(),
    'about': GlobalKey(),
    'skills': GlobalKey(),
    'projects': GlobalKey(),
    'experience': GlobalKey(),
    'workflow': GlobalKey(),
    'services': GlobalKey(),
    'testimonials': GlobalKey(),
    'contact': GlobalKey(),
  };
  String _activeSection = 'home';
  bool _didInitialScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateActiveSection);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateActiveSection)
      ..dispose();
    super.dispose();
  }

  void _updateActiveSection() {
    final offset = _scrollController.offset + 140;
    for (final entry in _sectionKeys.entries.toList().reversed) {
      final context = entry.value.currentContext;
      if (context == null) {
        continue;
      }
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) {
        continue;
      }
      final dy = box.localToGlobal(Offset.zero).dy + _scrollController.offset;
      if (offset >= dy && _activeSection != entry.key) {
        setState(() => _activeSection = entry.key);
        break;
      }
    }
  }

  Future<void> _scrollTo(String section) async {
    final key = _sectionKeys[section];
    final context = key?.currentContext;
    if (context == null) {
      return;
    }
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _navigateToTarget(String target) async {
    if (target == 'workflow-pipeline') {
      final pipelineContext = _workflowPipelineKey.currentContext;
      if (pipelineContext != null) {
        await Scrollable.ensureVisible(
          pipelineContext,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
          alignment: 0.12,
        );
      }
      return;
    }
    if (_sectionKeys.containsKey(target)) {
      await _scrollTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(portfolioControllerProvider);
    final controller = ref.read(portfolioControllerProvider.notifier);
    final isDark = ref.watch(appThemeModeProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (state.errorMessage != null || state.content == null) {
      return Scaffold(
        body: Center(child: Text(state.errorMessage ?? 'Unexpected error')),
      );
    }

    final content = state.content!;
    final selectedProject = state.selectedProjectIndex == null
        ? null
        : content.projects[state.selectedProjectIndex!];
    final profileName = content.profile.name;
    final profileSubtitle = content.profile.subtitle;
    final brandLabel = '${profileName.split(' ').first.toLowerCase()}.dev';
    final workflowContent = kAiWorkflowContent;

    if (!_didInitialScroll && widget.initialScrollSection != null) {
      _didInitialScroll = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }
        final target = widget.initialScrollSection!;
        final workflowReady = workflowContent.isVisible;
        if (target == 'workflow' && workflowReady) {
          await _scrollTo('workflow');
        } else if (target == 'workflow-pipeline' && workflowReady) {
          await _scrollTo('workflow');
          await _navigateToTarget('workflow-pipeline');
        } else if (target == 'workflow' || target == 'workflow-pipeline') {
          await _scrollTo('experience');
        } else if (_sectionKeys.containsKey(target)) {
          await _scrollTo(target);
        }
      });
    }

    final navSections = <String>[
      'home',
      'about',
      'skills',
      'projects',
      'experience',
      if (workflowContent.isVisible) 'workflow',
      'services',
      'contact',
    ];

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Builder(
            builder: (context) {
              final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.accent2.withValues(alpha: isDarkTheme ? 0.2 : 0.1),
                      AppColors.primary.withValues(alpha: isDarkTheme ? 0.12 : 0.05),
                      isDarkTheme ? AppColors.darkBg : AppColors.lightBg,
                    ],
                    radius: 1.2,
                    center: Alignment.topCenter,
                  ),
                ),
              );
            },
          ),
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: <Widget>[
                _HeroSection(
                  key: _sectionKeys['home'],
                  content: content,
                  onProjectsTap: () => _scrollTo('projects'),
                  onHireTap: () => _scrollTo('contact'),
                ),
                _AboutSection(
                  key: _sectionKeys['about'],
                  content: content,
                  onContactTap: () => _scrollTo('contact'),
                ),
                _SkillsSection(key: _sectionKeys['skills'], content: content),
                _ProjectsSection(
                  key: _sectionKeys['projects'],
                  projects: content.projects,
                  onProjectTap: controller.openProject,
                ),
                _ExperienceSection(
                  key: _sectionKeys['experience'],
                  timeline: content.timeline,
                ),
                if (workflowContent.isVisible)
                  AiWorkflowSection(
                    key: _sectionKeys['workflow'],
                    data: workflowContent,
                    onNavigate: _navigateToTarget,
                    pipelineAnchorKey: _workflowPipelineKey,
                  ),
                _ServicesSection(
                  key: _sectionKeys['services'],
                  services: content.services,
                ),
                _TestimonialsSection(
                  key: _sectionKeys['testimonials'],
                  testimonials: content.testimonials,
                  activeIndex: state.activeTestimonialIndex,
                  onDotTap: controller.setActiveTestimonial,
                ),
                _ContactSection(key: _sectionKeys['contact'], content: content),
                _Footer(content: content),
              ],
            ),
          ),
          _Navbar(
            activeSection: _activeSection,
            isDark: isDark,
            brandLabel: brandLabel,
            sections: navSections,
            onTap: _scrollTo,
            onToggleTheme: () => controller.setDarkMode(!isDark),
            onHireTap: () => _scrollTo('contact'),
          ),
          Positioned(
            right: state.showTweaks ? 320 : 32,
            bottom: 28,
            child: GradientButton(
              label: 'Hire Me',
              onTap: () => _scrollTo('contact'),
            ),
          ),
          if (state.showTweaks)
            Positioned(
              right: 24,
              bottom: 90,
              child: _TweaksPanel(
                isDark: isDark,
                onToggleTheme: (value) => controller.setDarkMode(value),
                onClose: () => controller.setShowTweaks(false),
              ),
            ),
          Positioned(
            right: 24,
            bottom: 24,
            child: IconButton.filled(
              onPressed: () => controller.setShowTweaks(!state.showTweaks),
              icon: Icon(state.showTweaks ? Icons.close : Icons.tune),
            ),
          ),
          if (selectedProject != null)
            _ProjectModal(
              project: selectedProject,
              onClose: controller.closeProject,
            ),
          if (state.showSplash)
            _SplashOverlay(
              onDone: controller.completeSplash,
              name: profileName,
              subtitle: profileSubtitle,
            ),
        ],
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  const _Navbar({
    required this.activeSection,
    required this.isDark,
    required this.brandLabel,
    required this.sections,
    required this.onTap,
    required this.onToggleTheme,
    required this.onHireTap,
  });

  final String activeSection;
  final bool isDark;
  final String brandLabel;
  final List<String> sections;
  final ValueChanged<String> onTap;
  final VoidCallback onToggleTheme;
  final VoidCallback onHireTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBg.withValues(alpha: 0.86)
                    : Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: <Widget>[
                  Text(
                    brandLabel,
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      children: sections
                          .map(
                            (item) => TextButton(
                              onPressed: () => onTap(item),
                              style: TextButton.styleFrom(
                                foregroundColor: activeSection == item
                                    ? AppColors.primary
                                    : _mutedText(context),
                              ),
                              child: Text(
                                item == 'workflow'
                                    ? 'Workflow'
                                    : item[0].toUpperCase() +
                                        item.substring(1),
                              ),
                            ),
                          )
                          .toList(growable: false),
                    ),
                  ),
                  IconButton(
                    onPressed: onToggleTheme,
                    icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                  ),
                  GradientButton(label: 'Hire Me', onTap: onHireTap),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.content,
    required this.onProjectsTap,
    required this.onHireTap,
    super.key,
  });

  final PortfolioContent content;
  final VoidCallback onProjectsTap;
  final VoidCallback onHireTap;

  @override
  Widget build(BuildContext context) {
    final profile = content.profile;
    final nameParts = profile.name.split(' ');
    final initials = nameParts
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();
    final width = MediaQuery.sizeOf(context).width;
    final twoColumns = width > 980;
    return Padding(
      padding: const EdgeInsets.only(top: 96, bottom: AppSpacing.section),
      child: ConstrainedContent(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      color: AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: const Text(
                      'Available for freelance work',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        const TextSpan(text: 'Hi, I am '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GradientText(
                            profile.name,
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 54,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile.subtitle,
                    style: TextStyle(
                      color: _mutedText(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    profile.description,
                    style: TextStyle(
                      color: _mutedText(context),
                      fontSize: 17,
                      height: 1.75,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      GradientButton(
                        label: 'View Projects',
                        onTap: onProjectsTap,
                      ),
                      GradientButton(
                        label: 'Hire Me',
                        onTap: onHireTap,
                        secondary: true,
                      ),
                      const GradientButton(label: 'Download CV', ghost: true),
                    ],
                  ),
                ],
              ),
            ),
            if (twoColumns) const SizedBox(width: 80),
            if (twoColumns)
              SizedBox(
                width: 360,
                child: GlassCard(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: <Color>[
                              AppColors.primary,
                              AppColors.accent1,
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 42,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        profile.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: _mutedText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({
    required this.content,
    required this.onContactTap,
    super.key,
  });

  final PortfolioContent content;
  final VoidCallback onContactTap;

  @override
  Widget build(BuildContext context) {
    final stats = resolveDisplayStats(content);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return _SectionBlock(
      title: 'Passionate about Flutter and beyond',
      label: 'About Me',
      child: ConstrainedContent(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Semantics(
                    label: 'About ${content.profile.name}',
                    child: Text(
                      content.profile.description,
                      style: TextStyle(
                        color: _mutedText(context),
                        height: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Focused on startup products with strong backend integration, release automation, and scalable delivery workflows.',
                    style: TextStyle(color: _mutedText(context), height: 1.8),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: content.skillCategories
                            .expand((category) => category.items)
                            .take(8)
                            .toSet()
                            .toList(growable: false)
                            .map(
                              (item) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0x334F6EF7),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(AppRadius.full),
                                  ),
                                ),
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                            .toList(growable: false),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GradientButton(label: 'Let us Talk', onTap: onContactTap),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final item = stats[index];
                  return GlassCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (reduceMotion)
                          Text(
                            '${item.value}${item.suffix}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 36,
                              color: hexToColor(item.color),
                            ),
                          )
                        else
                          TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 1400),
                            tween: Tween<double>(
                              begin: 0,
                              end: item.value.toDouble(),
                            ),
                            builder: (context, value, _) {
                              return Text(
                                '${value.round()}${item.suffix}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 36,
                                  color: hexToColor(item.color),
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 6),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _mutedText(context),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

class _SkillsSection extends StatelessWidget {
  const _SkillsSection({required this.content, super.key});

  final PortfolioContent content;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Skills. Technical expertise',
      child: _SectionBlock(
      label: 'Skills',
      title: 'Technical Expertise',
      background: AppColors.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.01 : 0.04,
      ),
      child: ConstrainedContent(
        child: Column(
          children: <Widget>[
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: content.skillRings
                  .map((skill) => _SkillRing(item: skill))
                  .toList(growable: false),
            ),
            const SizedBox(height: 64),
            GridView.builder(
              itemCount: content.skillCategories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final category = content.skillCategories[index];
                final color = hexToColor(category.color);
                return GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        category.title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...category.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: _mutedText(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ProjectsSection extends StatelessWidget {
  const _ProjectsSection({
    required this.projects,
    required this.onProjectTap,
    super.key,
  });

  final List<ProjectItem> projects;
  final ValueChanged<int> onProjectTap;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Projects',
      title: 'Featured Work',
      child: ConstrainedContent(
        child: GridView.builder(
          itemCount: projects.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 0.84,
          ),
          itemBuilder: (context, index) {
            final project = projects[index];
            final color = hexToColor(project.color);
            return GlassCard(
              hover: true,
              onTap: () => onProjectTap(index),
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppRadius.lg),
                          topRight: Radius.circular(AppRadius.lg),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        project.emoji,
                        style: const TextStyle(fontSize: 58),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.subtitle.toUpperCase(),
                          style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _mutedText(context),
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: project.stack
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    item,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ],
                    ),
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

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection({required this.timeline, super.key});

  final List<TimelineItem> timeline;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Experience',
      title: 'Career Journey',
      child: ConstrainedContent(
        child: Column(
          children: timeline
              .asMap()
              .entries
              .map(
                (entry) => _TimelineTile(
                  item: entry.value,
                  isLast: entry.key == timeline.length - 1,
                ),
              )
              .toList(growable: false),
        ),
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services, super.key});

  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Services',
      title: 'What I Offer',
      background: AppColors.primary.withValues(alpha: 0.02),
      child: ConstrainedContent(
        child: GridView.builder(
          itemCount: services.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
            childAspectRatio: 1.08,
          ),
          itemBuilder: (context, index) {
            final service = services[index];
            final color = hexToColor(service.color);
            return GlassCard(
              hover: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(service.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      service.description,
                      style: TextStyle(
                        color: _mutedText(context),
                        height: 1.7,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Learn more ->',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600),
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

class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection({
    required this.testimonials,
    required this.activeIndex,
    required this.onDotTap,
    super.key,
  });

  final List<TestimonialItem> testimonials;
  final int activeIndex;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    if (testimonials.isEmpty) {
      return const SizedBox.shrink();
    }
    final testimonial = testimonials[activeIndex];
    final color = hexToColor(testimonial.color);
    return _SectionBlock(
      label: 'Testimonials',
      title: 'Client Love',
      child: ConstrainedContent(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 760,
              child: GlassCard(
                child: Column(
                  children: <Widget>[
                    const Text('❝', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      testimonial.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mutedText(context),
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List<Widget>.generate(
                        testimonial.rating,
                        (_) => const Text(
                          '★',
                          style: TextStyle(color: AppColors.warning),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: color,
                      child: Text(
                        testimonial.avatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      testimonial.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      testimonial.role,
                      style: TextStyle(
                        color: _mutedText(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                testimonials.length,
                (index) => GestureDetector(
                  onTap: () => onDotTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: activeIndex == index ? 28 : 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      color: activeIndex == index
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection({required this.content, super.key});

  final PortfolioContent content;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final sent = ValueNotifier<bool>(false);
    return _SectionBlock(
      label: 'Contact',
      title: 'Let us Build Together',
      background: AppColors.primary.withValues(alpha: 0.02),
      child: ConstrainedContent(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Available for freelance projects, full-time roles, and collaborations. Response within 24 hours.',
                    style: TextStyle(color: _mutedText(context), height: 1.8),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...content.contacts.map(
                    (contact) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: Row(
                        children: <Widget>[
                          Text(
                            contact.icon,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                contact.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _mutedText(context),
                                ),
                              ),
                              Text(
                                contact.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xl),
            Expanded(
              child: GlassCard(
                child: ValueListenableBuilder<bool>(
                  valueListenable: sent,
                  builder: (context, value, _) {
                    if (value) {
                      return Column(
                        children: <Widget>[
                          Text('🎉', style: TextStyle(fontSize: 52)),
                          SizedBox(height: AppSpacing.md),
                          Text(
                            'Message Sent!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'I will get back within 24 hours.',
                            style: TextStyle(color: _mutedText(context)),
                          ),
                        ],
                      );
                    }
                    return Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Send a Message',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const _InputField(label: 'Your Name'),
                          const SizedBox(height: AppSpacing.md),
                          const _InputField(label: 'Email Address'),
                          const SizedBox(height: AppSpacing.md),
                          const _InputField(label: 'Message', maxLines: 5),
                          const SizedBox(height: AppSpacing.lg),
                          GradientButton(
                            label: 'Send Message',
                            onTap: () {
                              if (formKey.currentState?.validate() ?? false) {
                                sent.value = true;
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.content});

  final PortfolioContent content;

  @override
  Widget build(BuildContext context) {
    final profileName = content.profile.name;
    final brandLabel = '${profileName.split(' ').first.toLowerCase()}.dev';
    final year = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: ConstrainedContent(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              brandLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '© $year $profileName · Built with Flutter Web',
              style: TextStyle(color: _mutedText(context), fontSize: 13),
            ),
            Row(
              children: content.socials
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          item.label.substring(0, 1),
                          style: TextStyle(
                            color: _mutedText(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProjectModal extends StatelessWidget {
  const _ProjectModal({required this.project, required this.onClose});

  final ProjectItem project;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(project.color);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: isDark ? 0.8 : 0.45),
        child: Center(
          child: Container(
            width: 760,
            constraints: const BoxConstraints(maxHeight: 780),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : colorScheme.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),
                  child: Stack(
                    children: <Widget>[
                      Center(
                        child: Text(
                          project.emoji,
                          style: const TextStyle(fontSize: 82),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 20,
                        child: IconButton.filledTonal(
                          onPressed: onClose,
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          project.subtitle,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project.title,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          project.description,
                          style: TextStyle(
                            color: _mutedText(context),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Key Features',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ...project.features.map(
                          (feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.circle, size: 10, color: color),
                                const SizedBox(width: 8),
                                Text(
                                  feature,
                                  style: TextStyle(color: _mutedText(context)),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

class _SplashOverlay extends StatefulWidget {
  const _SplashOverlay({
    required this.onDone,
    required this.name,
    required this.subtitle,
  });

  final Future<void> Function() onDone;
  final String name;
  final String subtitle;

  @override
  State<_SplashOverlay> createState() => _SplashOverlayState();
}

class _SplashOverlayState extends State<_SplashOverlay> {
  double _opacity = 1;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2200), () async {
      if (!mounted) {
        return;
      }
      setState(() => _opacity = 0);
      await Future<void>.delayed(const Duration(milliseconds: 500));
      await widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 550),
      opacity: _opacity,
      child: Container(
        color: AppColors.darkBg,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _SpinnerLogo(),
              const SizedBox(height: AppSpacing.lg),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                widget.subtitle,
                style: TextStyle(color: _mutedText(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinnerLogo extends StatefulWidget {
  const _SpinnerLogo();

  @override
  State<_SpinnerLogo> createState() => _SpinnerLogoState();
}

class _SpinnerLogoState extends State<_SpinnerLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 88,
        height: 88,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[AppColors.primary, AppColors.accent1],
          ),
          borderRadius: BorderRadius.all(Radius.circular(22)),
        ),
        alignment: Alignment.center,
        child: const Text(
          'F',
          style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.label,
    required this.title,
    required this.child,
    this.background,
  });

  final String label;
  final String title;
  final Widget child;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: background,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.section),
      child: Column(
        children: <Widget>[
          ConstrainedContent(
            child: Column(
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
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          child,
        ],
      ),
    );
  }
}

class _SkillRing extends StatelessWidget {
  const _SkillRing({required this.item});

  final SkillRingItem item;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(item.color);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.55);
    return SizedBox(
      width: 94,
      child: Column(
        children: <Widget>[
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            tween: Tween<double>(begin: 0, end: item.percent / 100),
            builder: (context, value, _) {
              return CustomPaint(
                painter: _RingPainter(
                  progress: value,
                  color: color,
                  baseColor: baseColor,
                ),
                size: const Size.square(88),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(color: _mutedText(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.baseColor,
  });

  final double progress;
  final Color color;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = baseColor;
    final active = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawCircle(center, radius, base);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      active,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.baseColor != baseColor;
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.item, required this.isLast});

  final TimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(item.color);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 90,
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
          ],
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.period,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.role,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.company,
                  style: TextStyle(
                    color: _mutedText(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.description,
                  style: TextStyle(
                    color: _mutedText(context),
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.label, this.maxLines = 1});

  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class _TweaksPanel extends StatelessWidget {
  const _TweaksPanel({
    required this.isDark,
    required this.onToggleTheme,
    required this.onClose,
  });

  final bool isDark;
  final ValueChanged<bool> onToggleTheme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Tweaks',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Dark Mode',
                  style: TextStyle(color: _mutedText(context)),
                ),
                Switch(value: isDark, onChanged: onToggleTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
