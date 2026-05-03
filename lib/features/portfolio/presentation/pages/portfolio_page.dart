import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/constants/app_colors.dart';
import 'package:flutter_portfolio/core/constants/portfolio_assets.dart';
import 'package:flutter_portfolio/core/constants/app_radius.dart';
import 'package:flutter_portfolio/core/constants/app_spacing.dart';
import 'package:flutter_portfolio/core/layout/breakpoints.dart';
import 'package:flutter_portfolio/core/utils/color_utils.dart';
import 'package:flutter_portfolio/core/theme/app_theme.dart';
import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/constants/ai_workflow_content.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/state/portfolio_controller.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/utils/display_stats.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/widgets/ai_workflow_section.dart';
import 'package:flutter_portfolio/features/portfolio/presentation/widgets/portfolio_ui_primitives.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

Color _mutedText(BuildContext context) {
  return Theme.of(context).colorScheme.onSurfaceVariant;
}

bool _hasActionableUrl(String url) {
  final normalized = url.trim();
  return normalized.isNotEmpty && normalized != '#';
}

Future<void> _openExternalLink(BuildContext context, String url) async {
  if (!_hasActionableUrl(url)) {
    return;
  }
  final uri = Uri.tryParse(url.trim());
  if (uri == null) {
    return;
  }
  final didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!didLaunch && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to open link right now.')),
    );
  }
}

class PortfolioPage extends ConsumerStatefulWidget {
  const PortfolioPage({super.key, this.initialScrollSection});

  /// Optional section id for deep links (`workflow`, `projects`, `contact`, etc.).
  final String? initialScrollSection;

  @override
  ConsumerState<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends ConsumerState<PortfolioPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

    final viewportWidth = MediaQuery.sizeOf(context).width;
    final compactNav = Breakpoints.isCompactWidth(viewportWidth);

    return Scaffold(
      key: _scaffoldKey,
      drawer: compactNav
          ? _PortfolioDrawer(
              brandLabel: brandLabel,
              sections: navSections,
              activeSection: _activeSection,
              isDark: isDark,
              onSectionTap: (section) {
                Navigator.of(context).pop();
                _scrollTo(section);
              },
              onToggleTheme: () => controller.setDarkMode(!isDark),
              onHireTap: () {
                Navigator.of(context).pop();
                _scrollTo('contact');
              },
            )
          : null,
      body: Stack(
        children: <Widget>[
          Builder(
            builder: (context) {
              final isDarkTheme =
                  Theme.of(context).brightness == Brightness.dark;
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: <Color>[
                      AppColors.accent2.withValues(
                        alpha: isDarkTheme ? 0.2 : 0.1,
                      ),
                      AppColors.primary.withValues(
                        alpha: isDarkTheme ? 0.12 : 0.05,
                      ),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
            compact: compactNav,
            onOpenDrawer: compactNav
                ? () => _scaffoldKey.currentState?.openDrawer()
                : null,
            activeSection: _activeSection,
            isDark: isDark,
            brandLabel: brandLabel,
            sections: navSections,
            onTap: _scrollTo,
            onToggleTheme: () => controller.setDarkMode(!isDark),
            onHireTap: () => _scrollTo('contact'),
          ),
          Positioned(
            right: compactNav ? 8 : (state.showTweaks ? 16 : 24),
            bottom: 0,
            child: SafeArea(
              minimum: const EdgeInsets.only(right: 8, bottom: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  if (state.showTweaks)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _TweaksPanel(
                        isDark: isDark,
                        onToggleTheme: (value) => controller.setDarkMode(value),
                        onClose: () => controller.setShowTweaks(false),
                      ),
                    ),
                  GradientButton(
                    label: 'Hire Me',
                    onTap: () => _scrollTo('contact'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: () =>
                        controller.setShowTweaks(!state.showTweaks),
                    icon: Icon(state.showTweaks ? Icons.close : Icons.tune),
                  ),
                ],
              ),
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

class _PortfolioDrawer extends StatelessWidget {
  const _PortfolioDrawer({
    required this.brandLabel,
    required this.sections,
    required this.activeSection,
    required this.isDark,
    required this.onSectionTap,
    required this.onToggleTheme,
    required this.onHireTap,
  });

  final String brandLabel;
  final List<String> sections;
  final String activeSection;
  final bool isDark;
  final ValueChanged<String> onSectionTap;
  final VoidCallback onToggleTheme;
  final VoidCallback onHireTap;

  String _sectionTitle(String item) {
    return item == 'workflow'
        ? 'Workflow'
        : '${item[0].toUpperCase()}${item.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[AppColors.primary, AppColors.accent1],
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  brandLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),
            ),
            ...sections.map(
              (item) => ListTile(
                selected: activeSection == item,
                title: Text(_sectionTitle(item)),
                onTap: () => onSectionTap(item),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              title: Text(isDark ? 'Light mode' : 'Dark mode'),
              onTap: onToggleTheme,
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text('Hire Me'),
              onTap: onHireTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _Navbar extends StatelessWidget {
  const _Navbar({
    required this.compact,
    required this.onOpenDrawer,
    required this.activeSection,
    required this.isDark,
    required this.brandLabel,
    required this.sections,
    required this.onTap,
    required this.onToggleTheme,
    required this.onHireTap,
  });

  final bool compact;
  final VoidCallback? onOpenDrawer;
  final String activeSection;
  final bool isDark;
  final String brandLabel;
  final List<String> sections;
  final ValueChanged<String> onTap;
  final VoidCallback onToggleTheme;
  final VoidCallback onHireTap;

  String _sectionTitle(String item) {
    return item == 'workflow'
        ? 'Workflow'
        : '${item[0].toUpperCase()}${item.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = Breakpoints.contentHorizontalPadding(
      MediaQuery.sizeOf(context).width,
    );
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSpacing.maxContentWidth,
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: horizontal),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBg.withValues(alpha: 0.86)
                    : Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: compact
                  ? Row(
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: onOpenDrawer,
                          tooltip: 'Menu',
                        ),
                        Expanded(
                          child: Text(
                            brandLabel,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: <Widget>[
                        Text(
                          brandLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: sections
                                  .map(
                                    (item) => TextButton(
                                      onPressed: () => onTap(item),
                                      style: TextButton.styleFrom(
                                        foregroundColor: activeSection == item
                                            ? AppColors.primary
                                            : _mutedText(context),
                                      ),
                                      child: Text(_sectionTitle(item)),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: onToggleTheme,
                          icon: Icon(
                            isDark ? Icons.light_mode : Icons.dark_mode,
                          ),
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
    final width = MediaQuery.sizeOf(context).width;
    final twoColumns = Breakpoints.heroShowsSideAvatar(width);
    final headlineSize = width < Breakpoints.compact
        ? 34.0
        : width < Breakpoints.medium
        ? 44.0
        : 54.0;
    final subtitleSize = width < Breakpoints.compact ? 17.0 : 24.0;
    final bodySize = width < Breakpoints.compact ? 15.0 : 17.0;

    final Widget avatarCard = SizedBox(
      width: twoColumns ? 360 : double.infinity,
      child: GlassCard(
        child: Column(
          children: <Widget>[
            ClipOval(
              child: SizedBox(
                width: 120,
                height: 120,
                child: Image.asset(
                  PortfolioAssets.portfolioIcon,
                  fit: BoxFit.cover,
                  semanticLabel: 'Photo of ${profile.name}',
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: AppColors.primary,
                    child: Center(
                      child: Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              profile.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              profile.title,
              style: TextStyle(fontSize: 14, color: _mutedText(context)),
            ),
          ],
        ),
      ),
    );

    final Widget copyColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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
        MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: clampedHeroTextScaler(context)),
          child: Text.rich(
            TextSpan(
              children: <InlineSpan>[
                const TextSpan(text: 'Hi, I am '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GradientText(
                    profile.name,
                    style: TextStyle(
                      fontSize: headlineSize,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ),
            style: TextStyle(
              fontSize: headlineSize,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          profile.subtitle,
          style: TextStyle(
            color: _mutedText(context),
            fontSize: subtitleSize,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          profile.description,
          style: TextStyle(
            color: _mutedText(context),
            fontSize: bodySize,
            height: 1.75,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            GradientButton(label: 'View Projects', onTap: onProjectsTap),
            GradientButton(label: 'Hire Me', onTap: onHireTap, secondary: true),
            const GradientButton(label: 'Download CV', ghost: true),
          ],
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(
        top: Breakpoints.isCompactWidth(width) ? 88 : 96,
        bottom: AppSpacing.section,
      ),
      child: ConstrainedContent(
        child: twoColumns
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(child: copyColumn),
                  const SizedBox(width: 80),
                  avatarCard,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  copyColumn,
                  const SizedBox(height: AppSpacing.xl),
                  Center(child: avatarCard),
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
    final contentWidth = Breakpoints.portfolioContentWidth(context);
    return _SectionBlock(
      title: 'Passionate about Flutter and beyond',
      label: 'About Me',
      child: ConstrainedContent(
        child: Builder(
          builder: (context) {
            final wide = Breakpoints.useWideTwoColumns(contentWidth);
            const statsSpacing = AppSpacing.md;
            final statsBandWidth = wide
                ? (contentWidth - AppSpacing.xl) / 2
                : contentWidth;
            final statsCrossAxisCount = statsBandWidth < 340 ? 1 : 2;
            final statsTileWidth =
                (statsBandWidth - statsSpacing * (statsCrossAxisCount - 1)) /
                statsCrossAxisCount;
            final statsAspectRatio = statsCrossAxisCount == 1 ? 1.35 : 1.3;
            final statsValueSize = statsTileWidth < 150 ? 28.0 : 36.0;
            final statsGrid = GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: statsCrossAxisCount,
                crossAxisSpacing: statsSpacing,
                mainAxisSpacing: statsSpacing,
                childAspectRatio: statsAspectRatio,
              ),
              itemBuilder: (context, index) {
                final item = stats[index];
                return GlassCard(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (reduceMotion)
                          Text(
                            '${item.value}${item.suffix}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: statsValueSize,
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
                                  fontSize: statsValueSize,
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
                  ),
                );
              },
            );
            final copyColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Semantics(
                  label: 'About ${content.profile.name}',
                  child: Text(
                    content.profile.description,
                    style: TextStyle(color: _mutedText(context), height: 1.8),
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
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: copyColumn),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: statsGrid),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                copyColumn,
                const SizedBox(height: AppSpacing.xl),
                statsGrid,
              ],
            );
          },
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
          child: Builder(
            builder: (context) {
              final cw = Breakpoints.portfolioContentWidth(context);
              final cols = Breakpoints.responsiveGridCrossAxisCount(
                maxWidth: cw,
                maxColumns: 4,
                minTileWidth: 240,
              );
              final aspect = cols >= 3
                  ? 1.1
                  : cols == 2
                  ? 1.15
                  : 0.92;
              return Column(
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: aspect,
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
              );
            },
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
        child: Builder(
          builder: (context) {
            final cw = Breakpoints.portfolioContentWidth(context);
            final cols = Breakpoints.responsiveGridCrossAxisCount(
              maxWidth: cw,
              maxColumns: 3,
              minTileWidth: 280,
            );
            final aspect = cols >= 3
                ? 0.84
                : cols == 2
                ? 0.88
                : 0.72;
            return GridView.builder(
              itemCount: projects.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: AppSpacing.lg,
                mainAxisSpacing: AppSpacing.lg,
                childAspectRatio: aspect,
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
        child: Builder(
          builder: (context) {
            final cw = Breakpoints.portfolioContentWidth(context);
            final cols = Breakpoints.responsiveGridCrossAxisCount(
              maxWidth: cw,
              maxColumns: 3,
              minTileWidth: 260,
            );
            final gap = AppSpacing.lg;
            final tileWidth = (cw - gap * (cols - 1)) / cols;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (final service in services)
                  SizedBox(
                    width: tileWidth,
                    child: GlassCard(
                      hover: true,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            service.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            service.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            service.description,
                            style: TextStyle(
                              color: _mutedText(context),
                              height: 1.7,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
              width: double.infinity,
              child: Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
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
                            fontSize:
                                Breakpoints.isCompactWidth(
                                  MediaQuery.sizeOf(context).width,
                                )
                                ? 16
                                : 18,
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
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 8,
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

enum _ContactSubmitState { idle, submitting, success, error }

class _ContactSection extends StatefulWidget {
  const _ContactSection({required this.content, super.key});

  final PortfolioContent content;

  @override
  State<_ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<_ContactSection> {
  static const String _contactFormEndpoint = String.fromEnvironment(
    'CONTACT_FORM_ENDPOINT',
  );
  static const String _lastContactSubmitAtKey = 'last_contact_submit_at_ms';
  static const Duration _contactSubmitCooldown = Duration(minutes: 5);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  _ContactSubmitState _submitState = _ContactSubmitState.idle;
  String? _errorMessage;

  Future<Duration?> _getRemainingCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSubmitAtMs = prefs.getInt(_lastContactSubmitAtKey);
    if (lastSubmitAtMs == null) {
      return null;
    }
    final lastSubmitAt = DateTime.fromMillisecondsSinceEpoch(lastSubmitAtMs);
    final elapsed = DateTime.now().difference(lastSubmitAt);
    if (elapsed >= _contactSubmitCooldown) {
      return null;
    }
    return _contactSubmitCooldown - elapsed;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_contactFormEndpoint.isEmpty) {
      setState(() {
        _submitState = _ContactSubmitState.error;
        _errorMessage =
            'Contact service is not configured yet. Please use email or phone below.';
      });
      return;
    }

    final remainingCooldown = await _getRemainingCooldown();
    if (remainingCooldown != null) {
      final minutes = remainingCooldown.inMinutes;
      final seconds = remainingCooldown.inSeconds.remainder(60);
      final waitText = minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
      setState(() {
        _submitState = _ContactSubmitState.error;
        _errorMessage = 'Please wait $waitText before sending another message.';
      });
      return;
    }

    setState(() {
      _submitState = _ContactSubmitState.submitting;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(_contactFormEndpoint);
      final isFormspree = uri.host.endsWith('formspree.io');

      late final http.Response response;
      if (isFormspree) {
        final body = Uri(
          queryParameters: <String, String>{
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            '_replyto': _emailController.text.trim(),
            'message': _messageController.text.trim(),
            'source': 'portfolio-web',
            'submittedAt': DateTime.now().toIso8601String(),
          },
        ).query;

        response = await http.post(
          uri,
          headers: const <String, String>{
            'Content-Type': 'application/x-www-form-urlencoded',
            'Accept': 'application/json',
          },
          body: body,
        );
      } else {
        response = await http.post(
          uri,
          headers: const <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(<String, String>{
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'message': _messageController.text.trim(),
            'source': 'portfolio-web',
            'submittedAt': DateTime.now().toIso8601String(),
          }),
        );
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Request failed: ${response.statusCode}');
      }

      if (!mounted) {
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastContactSubmitAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      setState(() {
        _submitState = _ContactSubmitState.success;
      });
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _submitState = _ContactSubmitState.error;
        _errorMessage =
            'Message could not be sent right now. Please contact via email or phone.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SectionBlock(
      label: 'Contact',
      title: 'Let us Build Together',
      background: AppColors.primary.withValues(alpha: 0.02),
      child: ConstrainedContent(
        child: Builder(
          builder: (context) {
            final cw = Breakpoints.portfolioContentWidth(context);
            final wide = Breakpoints.useWideTwoColumns(cw);
            final contactsColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Available for freelance projects, full-time roles, and collaborations. Response within 24 hours.',
                  style: TextStyle(color: _mutedText(context), height: 1.8),
                ),
                const SizedBox(height: AppSpacing.lg),
                ...widget.content.contacts.map(
                  (contact) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InkWell(
                      onTap: _hasActionableUrl(contact.url)
                          ? () => _openExternalLink(context, contact.url)
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          children: <Widget>[
                            Text(
                              contact.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
            final formCard = GlassCard(
              child: _submitState == _ContactSubmitState.success
                  ? Column(
                      children: <Widget>[
                        const Text('🎉', style: TextStyle(fontSize: 52)),
                        const SizedBox(height: AppSpacing.md),
                        const Text(
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
                        const SizedBox(height: AppSpacing.lg),
                        GradientButton(
                          label: 'Send Another',
                          secondary: true,
                          onTap: () {
                            setState(() {
                              _submitState = _ContactSubmitState.idle;
                            });
                          },
                        ),
                      ],
                    )
                  : Form(
                      key: _formKey,
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
                          _InputField(
                            label: 'Your Name',
                            controller: _nameController,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _InputField(
                            label: 'Email Address',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final text = value?.trim() ?? '';
                              if (text.isEmpty) {
                                return 'Required';
                              }
                              final emailRegex = RegExp(
                                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                              );
                              if (!emailRegex.hasMatch(text)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _InputField(
                            label: 'Message',
                            controller: _messageController,
                            maxLines: 5,
                          ),
                          if (_submitState ==
                              _ContactSubmitState.error) ...<Widget>[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _errorMessage ?? 'Something went wrong.',
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          GradientButton(
                            label:
                                _submitState == _ContactSubmitState.submitting
                                ? 'Sending...'
                                : 'Send Message',
                            onTap:
                                _submitState == _ContactSubmitState.submitting
                                ? null
                                : _handleSubmit,
                          ),
                        ],
                      ),
                    ),
            );
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: contactsColumn),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(child: formCard),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                contactsColumn,
                const SizedBox(height: AppSpacing.xl),
                formCard,
              ],
            );
          },
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
        child: Builder(
          builder: (context) {
            final cw = Breakpoints.portfolioContentWidth(context);
            final socialRow = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: content.socials
                  .map(
                    (item) => InkWell(
                      onTap: _hasActionableUrl(item.url)
                          ? () => _openExternalLink(context, item.url)
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        width: 34,
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.06)
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
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
            );
            final footerCredit = kIsWeb
                ? '© $year $profileName'
                : '© $year $profileName · Built with Flutter Web';
            if (Breakpoints.useWideTwoColumns(cw)) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    brandLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Expanded(
                    child: Text(
                      footerCredit,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mutedText(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  socialRow,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  brandLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  footerCredit,
                  style: TextStyle(color: _mutedText(context), fontSize: 13),
                ),
                const SizedBox(height: AppSpacing.md),
                socialRow,
              ],
            );
          },
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
    final mq = MediaQuery.of(context);
    final maxModalWidth = (mq.size.width - mq.padding.horizontal - 24).clamp(
      280.0,
      760.0,
    );
    final maxModalHeight = (mq.size.height - mq.padding.vertical - 24).clamp(
      320.0,
      780.0,
    );
    final headerHeight = mq.size.height < 640 ? 160.0 : 220.0;
    final titleFontSize = mq.size.width < Breakpoints.compact ? 26.0 : 34.0;
    final emojiSize = mq.size.width < Breakpoints.compact ? 64.0 : 82.0;
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: isDark ? 0.8 : 0.45),
        child: SafeArea(
          minimum: const EdgeInsets.all(12),
          child: Center(
            child: Container(
              width: maxModalWidth,
              constraints: BoxConstraints(maxHeight: maxModalHeight),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: headerHeight,
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
                            style: TextStyle(fontSize: emojiSize),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
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
                            style: TextStyle(
                              fontSize: titleFontSize,
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(Icons.circle, size: 10, color: color),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      feature,
                                      style: TextStyle(
                                        color: _mutedText(context),
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
                ],
              ),
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
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize:
                        MediaQuery.sizeOf(context).width < Breakpoints.compact
                        ? 30
                        : MediaQuery.sizeOf(context).width < Breakpoints.medium
                        ? 38
                        : 48,
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
                  style: TextStyle(color: _mutedText(context), fontSize: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  item.description,
                  style: TextStyle(color: _mutedText(context), height: 1.7),
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
  const _InputField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
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
                Text('Dark Mode', style: TextStyle(color: _mutedText(context))),
                Switch(value: isDark, onChanged: onToggleTheme),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
