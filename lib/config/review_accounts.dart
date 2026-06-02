import '../models/auth_role.dart';

class ReviewAccount {
  const ReviewAccount({
    required this.email,
    required this.password,
    required this.role,
    required this.label,
  });

  final String email;
  final String password;
  final UserRole role;
  final String label;
}

class ReviewAccounts {
  ReviewAccounts._();

  static const password = 'SijangReview2026!';

  static const user = ReviewAccount(
    email: 'review-user@sijangyeojido.com',
    password: password,
    role: UserRole.customer,
    label: '일반 사용자',
  );

  static const merchant = ReviewAccount(
    email: 'review-merchant@sijangyeojido.com',
    password: password,
    role: UserRole.merchant,
    label: '시장 상인',
  );

  static const admin = ReviewAccount(
    email: 'review-admin@sijangyeojido.com',
    password: password,
    role: UserRole.admin,
    label: '운영자',
  );

  static const all = [user, merchant, admin];

  static ReviewAccount forRole(UserRole role) {
    return switch (role) {
      UserRole.merchant => merchant,
      UserRole.admin => admin,
      UserRole.customer => user,
    };
  }
}
