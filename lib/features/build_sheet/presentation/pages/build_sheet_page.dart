import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_portfolio/core/theme/app_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/hero_section.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/info_sections.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_header.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/work_section.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "Build Sheet" portfolio: a drafting-sheet layout with a mono metadata
/// rail, large grotesk headlines, hairline rules and one live demo device.
class BuildSheetPage extends ConsumerStatefulWidget {
  const BuildSheetPage({super.key, this.initialSection});

  /// Optional deep link: `work`, `capabilities`, `experience` or `contact`.
  final String? initialSection;

  @override
  ConsumerState<BuildSheetPage> createState() => _BuildSheetPageState();
}

class _BuildSheetPageState extends ConsumerState<BuildSheetPage>
    with SingleTickerProviderStateMixin {
  static const String _prefDarkMode = 'portfolio_dark_mode';

  final ScrollController _scroll = ScrollController();
  final ValueNotifier<double> _progress = ValueNotifier<double>(0);
  final Map<SheetSection, GlobalKey> _keys = <SheetSection, GlobalKey>{
    SheetSection.work: GlobalKey(),
    SheetSection.capabilities: GlobalKey(),
    SheetSection.experience: GlobalKey(),
    SheetSection.contact: GlobalKey(),
  };

  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (kIntroSeconds * 1000).round()),
  );
  bool _introStarted = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _restoreTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openInitialSection());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_introStarted) {
      return;
    }
    _introStarted = true;
    if (reduceMotion(context)) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    _progress.dispose();
    _intro.dispose();
    super.dispose();
  }

  Future<void> _restoreTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(_prefDarkMode);
      if (saved != null && mounted) {
        ref.read(appThemeModeProvider.notifier).state = saved;
      }
    } catch (_) {
      // Keep the platform default when preferences are unavailable.
    }
  }

  Future<void> _toggleTheme() async {
    final next = !ref.read(appThemeModeProvider);
    ref.read(appThemeModeProvider.notifier).state = next;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefDarkMode, next);
    } catch (_) {
      // Theme still switches for this session.
    }
  }

  void _onScroll() {
    if (!_scroll.hasClients) {
      return;
    }
    final max = _scroll.position.maxScrollExtent;
    _progress.value = max <= 0 ? 0 : (_scroll.offset / max).clamp(0.0, 1.0);
  }

  void _openInitialSection() {
    final id = widget.initialSection;
    if (id == null || !mounted) {
      return;
    }
    for (final section in SheetSection.values) {
      if (section.name == id) {
        _goTo(section, animate: false);
        return;
      }
    }
  }

  void _goTo(SheetSection section, {bool animate = true}) {
    if (!_scroll.hasClients) {
      return;
    }
    double target = 0;
    if (section != SheetSection.top) {
      final box = _keys[section]?.currentContext?.findRenderObject();
      if (box == null) {
        return;
      }
      final viewport = RenderAbstractViewport.of(box);
      target = viewport.getOffsetToReveal(box, 0).offset - 72;
    }
    target = target.clamp(0.0, _scroll.position.maxScrollExtent);
    if (!animate || reduceMotion(context)) {
      _scroll.jumpTo(target);
      return;
    }
    _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: p.accent.withValues(alpha: 0.4),
          cursorColor: p.accent,
        ),
      ),
      child: Scaffold(
        backgroundColor: p.bg,
        body: Stack(
          children: <Widget>[
            Positioned.fill(
              child: SingleChildScrollView(
                controller: _scroll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    SizedBox(height: Sheet.headerHeight + 1 + topInset),
                    SheetWrap(child: HeroSection(intro: _intro)),
                    SheetWrap(
                      child: KeyedSubtree(
                        key: _keys[SheetSection.work],
                        child: const WorkSection(),
                      ),
                    ),
                    SheetWrap(
                      child: KeyedSubtree(
                        key: _keys[SheetSection.capabilities],
                        child: const CapabilitiesSection(),
                      ),
                    ),
                    SheetWrap(
                      child: KeyedSubtree(
                        key: _keys[SheetSection.experience],
                        child: const ExperienceSection(),
                      ),
                    ),
                    SheetWrap(
                      child: KeyedSubtree(
                        key: _keys[SheetSection.contact],
                        child: const ContactSection(),
                      ),
                    ),
                    SheetFooter(onTop: () => _goTo(SheetSection.top)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _intro,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: SheetHeader(
                    onNavigate: _goTo,
                    onToggleTheme: _toggleTheme,
                  ),
                ),
                builder: (BuildContext context, Widget? child) {
                  final v = kExpoOut.transform(introSeg(_intro.value, 0, 0.8));
                  return FractionalTranslation(
                    translation: Offset(0, v - 1),
                    child: child,
                  );
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: IgnorePointer(
                child: ValueListenableBuilder<double>(
                  valueListenable: _progress,
                  builder: (BuildContext context, double value, Widget? _) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: value,
                        child: ColoredBox(
                          color: p.accent,
                          child: const SizedBox.expand(),
                        ),
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
