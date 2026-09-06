import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/auth/domain/entities/app_user.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

void main() {
  group('UserRole mapping', () {
    test('maps known database strings to roles', () {
      expect(UserRoleX.fromWireName('owner'), UserRole.owner);
      expect(UserRoleX.fromWireName('manager'), UserRole.manager);
      expect(UserRoleX.fromWireName('receptionist'), UserRole.receptionist);
    });

    test('returns null for unknown or missing roles (safe failure)', () {
      expect(UserRoleX.fromWireName('admin'), isNull);
      expect(UserRoleX.fromWireName('owner2'), isNull);
      expect(UserRoleX.fromWireName(null), isNull);
      expect(UserRoleX.fromWireName(''), isNull);
    });

    test('labels are human-readable', () {
      expect(UserRole.owner.label, 'Owner');
      expect(UserRole.manager.label, 'Manager');
      expect(UserRole.receptionist.label, 'Receptionist');
    });

    test('role helpers reflect membership', () {
      expect(UserRole.owner.isOwner, isTrue);
      expect(UserRole.owner.isOwnerOrManager, isTrue);
      expect(UserRole.owner.canManageEmployees, isTrue);
      expect(UserRole.manager.isOwner, isFalse);
      expect(UserRole.manager.isOwnerOrManager, isTrue);
      expect(UserRole.manager.canManageBranches, isTrue);
      expect(UserRole.receptionist.isReceptionist, isTrue);
      expect(UserRole.receptionist.isOwnerOrManager, isFalse);
      expect(UserRole.receptionist.canManageEmployees, isFalse);
    });
  });

  group('UserProfile', () {
    test('defaults to active and can hold an org context', () {
      const profile = UserProfile(
        id: 'u1',
        organizationId: 'org-1',
        role: UserRole.manager,
      );
      expect(profile.isActive, isTrue);
      expect(profile.branchId, isNull);
      expect(profile.fullName, isNull);
    });

    test('supports copyWith', () {
      const profile = UserProfile(id: 'u1', role: UserRole.owner);
      final updated = profile.copyWith(fullName: 'Alex', isActive: false);
      expect(updated.fullName, 'Alex');
      expect(updated.isActive, isFalse);
      expect(updated.id, 'u1');
    });

    test('value equality', () {
      const a = UserProfile(id: 'u1', role: UserRole.owner);
      const b = UserProfile(id: 'u1', role: UserRole.owner);
      expect(a, b);
    });
  });

  group('AppUser', () {
    test('delegates business identity to the profile', () {
      final user = AppUser(
        id: 'u1',
        email: 'owner@gym.test',
        profile: const UserProfile(
          id: 'u1',
          organizationId: 'org-1',
          branchId: 'b-1',
          fullName: 'Alex Owner',
          role: UserRole.owner,
        ),
      );
      expect(user.fullName, 'Alex Owner');
      expect(user.organizationId, 'org-1');
      expect(user.branchId, 'b-1');
      expect(user.role, UserRole.owner);
      expect(user.isActive, isTrue);
      expect(user.email, 'owner@gym.test');
    });

    test('fullName falls back to email', () {
      final user = AppUser(
        id: 'u1',
        email: 'owner@gym.test',
        profile: const UserProfile(
          id: 'u1',
          organizationId: 'org-1',
          role: UserRole.owner,
        ),
      );
      expect(user.fullName, 'owner@gym.test');
    });

    test('supports copyWith and value equality', () {
      final a = AppUser(
        id: 'u1',
        email: 'a@gym.test',
        profile: const UserProfile(id: 'u1', role: UserRole.owner),
      );
      final b = AppUser(
        id: 'u1',
        email: 'a@gym.test',
        profile: const UserProfile(id: 'u1', role: UserRole.owner),
      );
      expect(a, b);
      expect(a.copyWith(email: 'b@gym.test').email, 'b@gym.test');
    });
  });
}
