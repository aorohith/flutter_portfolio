import 'package:flutter/material.dart';
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
          const AvailabilityRow(),
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
