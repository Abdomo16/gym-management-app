import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    test('defaults to the least-privileged role', () {
      const user = AppUser(id: 'u1', email: 'staff@gym.test');
      expect(user.role, UserRole.receptionist);
    });

    test('supports copyWith', () {
      const user = AppUser(id: 'u1', email: 'a@gym.test');
      final renamed = user.copyWith(displayName: 'Alex');
      expect(renamed.displayName, 'Alex');
      expect(renamed.email, 'a@gym.test');
      expect(renamed.role, user.role);
    });

    test('value equality', () {
      const a = AppUser(id: 'u1', email: 'a@gym.test');
      const b = AppUser(id: 'u1', email: 'a@gym.test');
      expect(a, b);
    });

    test('UserRoleX.fromWireName maps roles and falls back safely', () {
      expect(UserRoleX.fromWireName('owner'), UserRole.owner);
      expect(UserRoleX.fromWireName('manager'), UserRole.manager);
      expect(UserRoleX.fromWireName('receptionist'), UserRole.receptionist);
      expect(UserRoleX.fromWireName('admin'), UserRole.receptionist);
      expect(UserRoleX.fromWireName(null), UserRole.receptionist);
    });
  });
}
