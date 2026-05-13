import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0B1D3A),
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x060B1D3A),
      blurRadius: 6,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadowMedium = [
    BoxShadow(
      color: Color(0x121A56DB),
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x080B1D3A),
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> cardShadowLarge = [
    BoxShadow(
      color: Color(0x1A1A56DB),
      blurRadius: 40,
      offset: Offset(0, 16),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x0A0B1D3A),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x401A56DB),
      blurRadius: 20,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> navShadow = [
    BoxShadow(
      color: Color(0x120B1D3A),
      blurRadius: 24,
      offset: Offset(0, -4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> floatingButtonShadow = [
    BoxShadow(
      color: Color(0x4D1A56DB),
      blurRadius: 28,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Color(0x201A56DB),
      blurRadius: 8,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
}