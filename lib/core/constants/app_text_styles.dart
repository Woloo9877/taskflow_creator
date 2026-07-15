import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headline(Color color) => TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      );

  static TextStyle sectionTitle(Color color) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle taskTitle(Color color) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle body(Color color) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle button(Color color) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle ringPercentage(Color color) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: color,
      );
}