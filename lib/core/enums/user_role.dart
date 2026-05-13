enum UserRole {
  guest,
  student,
  mentor;

  String get displayName {
    switch (this) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.student:
        return 'Student';
      case UserRole.mentor:
        return 'Mentor / Professional';
    }
  }

  bool get requiresAuth => this != UserRole.guest;
}