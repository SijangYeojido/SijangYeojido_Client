enum UserRole { customer, merchant, admin }

UserRole roleFromServer(String? role) {
  switch ((role ?? '').toUpperCase()) {
    case 'MERCHANT':
      return UserRole.merchant;
    case 'ADMIN':
    case 'MANAGER':
      return UserRole.admin;
    case 'USER':
    default:
      return UserRole.customer;
  }
}

extension UserRoleServerValue on UserRole {
  String toServerRole() {
    switch (this) {
      case UserRole.customer:
        return 'USER';
      case UserRole.merchant:
        return 'MERCHANT';
      case UserRole.admin:
        return 'ADMIN';
    }
  }
}
