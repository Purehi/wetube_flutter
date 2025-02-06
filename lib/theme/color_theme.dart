import 'package:flutter/material.dart';
ColorScheme lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Colors.black,
  onPrimary: Colors.grey,
  primaryContainer: Colors.black,
  onPrimaryContainer: Colors.grey.shade100,
  secondary: Colors.grey.shade800,
  onSecondary: Colors.grey.shade300,
  error: Colors.redAccent,
  onError: Colors.red,
  surface: Colors.white,
  onSurface: Colors.white,
);
ColorScheme darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.white,
  onPrimary: Colors.grey,
  primaryContainer: Colors.white,
  onPrimaryContainer: Colors.grey.shade900,
  secondary: Colors.white,
  onSecondary: Colors.grey.shade700,
  error: Colors.redAccent,
  onError: Colors.red,
  surface: Colors.black,
  onSurface: Colors.black38,
);