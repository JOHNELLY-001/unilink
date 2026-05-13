enum EducationLevel {
  form4,
  form5,
  form6,
  university,
  graduate;

  String get displayName {
    switch (this) {
      case EducationLevel.form4:
        return 'Form 4';
      case EducationLevel.form5:
        return 'Form 5';
      case EducationLevel.form6:
        return 'Form 6';
      case EducationLevel.university:
        return 'University';
      case EducationLevel.graduate:
        return 'Graduate';
    }
  }

  String get shortLabel {
    switch (this) {
      case EducationLevel.form4:
        return 'F4';
      case EducationLevel.form5:
        return 'F5';
      case EducationLevel.form6:
        return 'F6';
      case EducationLevel.university:
        return 'UNI';
      case EducationLevel.graduate:
        return 'GRAD';
    }
  }
}