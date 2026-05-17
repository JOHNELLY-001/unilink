import 'package:flutter/material.dart';
import '../enums/education_level.dart';

extension StringExtension on String {
  String get capitalised =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((word) => word.capitalised)
      .join(' ');

  bool get isValidEmail =>
      RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
}

extension DateTimeExtension on DateTime {
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).round()}w ago';
  }

  String get formatted {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day, $year';
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  ThemeData get theme => Theme.of(this);
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600;
}

extension EducationLevelExtension on EducationLevel {
  bool get isSecondarySchool =>
      this == EducationLevel.form4 ||
          this == EducationLevel.form5 ||
          this == EducationLevel.form6;
}