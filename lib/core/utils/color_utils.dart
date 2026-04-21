import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  final value = cleaned.length == 6 ? 'FF$cleaned' : cleaned;
  return Color(int.parse(value, radix: 16));
}
