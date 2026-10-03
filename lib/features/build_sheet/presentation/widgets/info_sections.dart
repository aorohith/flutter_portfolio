import 'package:flutter/material.dart';
import 'package:flutter_portfolio/core/constants/portfolio_assets.dart';
import 'package:flutter_portfolio/features/build_sheet/data/sheet_content.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/theme/sheet_theme.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_motion.dart';
import 'package:flutter_portfolio/features/build_sheet/presentation/widgets/sheet_widgets.dart';

class CapabilitiesSection extends StatelessWidget {
  const CapabilitiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final items = SheetContent.capabilities;

    return SheetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHead(kicker: 'Capabilities', title: 'What I do, by job'),
          for (var i = 0; i < items.length; i++)
            Reveal(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: p.line),
                    bottom: i == items.length - 1
                        ? BorderSide(color: p.line)
                        : BorderSide.none,
                  ),
                ),
                child: SheetColumns(
                  gap: 48,
                  rowGap: 10,
                  left: Text(
                    items[i].title,
                    style: SheetType.display(
                      p.fg,
                      20,
                      tracking: -0.015,
                      height: 1.2,
                    ),
                  ),
                  right: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final tag in items[i].tags) _Tag(tag),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.line),
      ),
      child: Text(text, style: SheetType.mono(p.fg, 12.8, height: 1.5)),
    );
  }
}

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return SheetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHead(kicker: 'Experience', title: 'Where I work'),
          Reveal(
            child: SheetColumns(
              gap: 48,
              rowGap: 10,
              left: MonoLabel(SheetContent.jobPeriod),
              right: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    SheetContent.jobTitle,
                    style: SheetType.display(
                      p.fg,
                      Sheet.fluid(width, 28.8, 3.2, 41.6),
                      tracking: -0.025,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(
                      SheetContent.jobBody,
                      style: SheetType.body(p.muted, 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
          for (final row in SheetContent.education)
            Reveal(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: SheetColumns(
                  gap: 48,
                  rowGap: 8,
                  left: MonoLabel(row.period),
                  right: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Text(row.text, style: SheetType.body(p.fg, 18)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = Sheet.fluid(width, 44.8, 9, 112);

    return SheetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Reveal(child: MonoLabel('Contact')),
          const SizedBox(height: 16),
          Reveal(
            dy: 50,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: titleSize * 7.2),
              child: Semantics(
                header: true,
                child: Text(
                  SheetContent.contactTitle,
                  style: SheetType.display(
                    p.fg,
                    titleSize,
                    tracking: -0.045,
                    height: 0.95,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Reveal(
            child: SelectableText(
              SheetContent.email,
              style: SheetType.mono(
                p.fg,
                Sheet.fluid(width, 16.8, 2.8, 25.6),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Reveal(child: ActionRow(includeResume: true)),
          const SizedBox(height: 22),
          const AvailabilityRow(text: SheetContent.contactAvailability),
        ],
      ),
    );
  }
}

class SheetFooter extends StatelessWidget {
  const SheetFooter({required this.onTop, super.key});

  final VoidCallback onTop;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Sheet.gutter(width)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: p.line)),
        ),
        padding: const EdgeInsets.only(top: 28, bottom: 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Sheet.maxWidth),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 32,
              runSpacing: 12,
              children: <Widget>[
                const MonoLabel(SheetContent.footerLeft),
                Pressable(
                  onTap: onTop,
                  label: 'Back to top',
                  builder: (BuildContext context, bool hovered) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 44),
                      child: Align(
                        widthFactor: 1,
                        child: Text(
                          'BACK TO TOP',
                          style: SheetType.label(p).copyWith(
                            color: hovered ? p.accent : p.muted,
                            decoration: TextDecoration.underline,
                            decorationColor: p.accent,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Portrait plus a short bio. The photo is greyscale until hovered.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = Sheet.isNarrow(width);
    final bigSize = Sheet.fluid(width, 24, 2.8, 35.2);

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Semantics(
          header: true,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: bigSize * 15),
            child: Reveal(
              child: Text(
                SheetContent.aboutBig,
                style: SheetType.display(
                  p.fg,
                  bigSize,
                  weight: FontWeight.w600,
                  tracking: -0.02,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
        for (final paragraph in SheetContent.aboutBody) ...<Widget>[
          const SizedBox(height: 18),
          Reveal(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Text(paragraph, style: SheetType.body(p.muted, 16.8)),
            ),
          ),
        ],
      ],
    );

    final gap = Sheet.fluid(width, 24, 4, 56);
    final inner = narrow
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: const _Portrait(),
              ),
              SizedBox(height: gap),
              copy,
            ],
          )
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(width: 260, child: _Portrait()),
              SizedBox(width: gap),
              Expanded(child: copy),
            ],
          );

    return SheetBlock(
      child: SheetColumns(
        gap: 48,
        rowGap: 28,
        left: const Reveal(child: MonoLabel('About')),
        right: inner,
      ),
    );
  }
}

class _Portrait extends StatefulWidget {
  const _Portrait();

  @override
  State<_Portrait> createState() => _PortraitState();
}

class _PortraitState extends State<_Portrait> {
  bool _hover = false;

  static ColorFilter _saturation(double s) {
    const r = 0.2126;
    const g = 0.7152;
    const b = 0.0722;
    final inv = 1 - s;
    return ColorFilter.matrix(<double>[
      r * inv + s, g * inv, b * inv, 0, 0, //
      r * inv, g * inv + s, b * inv, 0, 0, //
      r * inv, g * inv, b * inv + s, 0, 0, //
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    return Reveal(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 1,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(end: _hover ? 1 : 0),
                  duration: const Duration(milliseconds: 600),
                  curve: kExpoOut,
                  builder: (BuildContext context, double t, Widget? child) {
                    return ColorFiltered(
                      colorFilter: _saturation(t),
                      child: child,
                    );
                  },
                  child: Semantics(
                    image: true,
                    label: 'Portrait of Rohith A O',
                    child: Image.asset(
                      PortfolioAssets.portrait,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.medium,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            MonoLabel(SheetContent.portraitCaption, color: p.muted),
          ],
        ),
      ),
    );
  }
}

/// Six service cards in a hairline grid (3, 2 or 1 columns by width).
class ServicesSection extends StatelessWidget {
  const ServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final columns = width <= 560 ? 1 : (width <= 900 ? 2 : 3);
    final items = SheetContent.services;
    final rows = <List<ServiceItem>>[
      for (var i = 0; i < items.length; i += columns)
        items.sublist(
          i,
          i + columns > items.length ? items.length : i + columns,
        ),
    ];

    return SheetBlock(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const SectionHead(
            kicker: 'Services',
            title: 'What I can build for you',
            lead: SheetContent.servicesLead,
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: p.line),
                left: BorderSide(color: p.line),
              ),
            ),
            child: Column(
              children: <Widget>[
                for (var r = 0; r < rows.length; r++)
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        for (var c = 0; c < columns; c++)
                          Expanded(
                            child: c < rows[r].length
                                ? Reveal(
                                    delay: Duration(
                                      milliseconds: 70 * (r * columns + c),
                                    ),
                                    dy: 22,
                                    child: _ServiceCell(item: rows[r][c]),
                                  )
                                : const SizedBox.shrink(),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCell extends StatefulWidget {
  const _ServiceCell({required this.item});

  final ServiceItem item;

  @override
  State<_ServiceCell> createState() => _ServiceCellState();
}

class _ServiceCellState extends State<_ServiceCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = SheetPalette.of(context);
    final item = widget.item;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        decoration: BoxDecoration(
          color: _hover ? p.surface : Colors.transparent,
          border: Border(
            right: BorderSide(color: p.line),
            bottom: BorderSide(color: p.line),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              item.kind.toUpperCase(),
              style: SheetType.label(p).copyWith(color: p.accent),
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: SheetType.display(p.fg, 21.6, tracking: -0.015),
            ),
            const SizedBox(height: 10),
            Text(item.description, style: SheetType.body(p.muted, 15.7)),
          ],
        ),
      ),
    );
  }
}
