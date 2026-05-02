import 'package:flutter/material.dart';

/// Published by [ConstrainedContent] so descendants read the actual laid-out
/// inner width (after horizontal padding and max-width cap).
final class ContentWidthScope extends InheritedWidget {
  const ContentWidthScope({
    required this.width,
    required super.child,
    super.key,
  });

  final double width;

  static double? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ContentWidthScope>()
        ?.width;
  }

  @override
  bool updateShouldNotify(ContentWidthScope oldWidget) =>
      oldWidget.width != width;
}
