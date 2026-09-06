import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/data/mappers/profile_mapper.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';

void main() {
  group('ProfileMapper', () {
    test('maps a full profile row', () {
      final profile = ProfileMapper.fromMap({
        'id': 'u1',
        'organization_id': 'org-1',
        'branch_id': 'b-1',
        'full_name': 'Alex Owner',
        'phone': '+201000000000',
        'role': 'owner',
        'avatar_url': 'https://cdn.example.com/a.png',
        'is_active': true,
      });

      expect(profile.id, 'u1');
      expect(profile.organizationId, 'org-1');
      expect(profile.branchId, 'b-1');
      expect(profile.fullName, 'Alex Owner');
      expect(profile.phone, '+201000000000');
      expect(profile.role, UserRole.owner);
      expect(profile.avatarUrl, 'https://cdn.example.com/a.png');
      expect(profile.isActive, isTrue);
    });

    test('maps a minimal row with defaults', () {
      final profile = ProfileMapper.fromMap({
        'id': 'u1',
        'role': 'receptionist',
      });
      expect(profile.organizationId, isNull);
      expect(profile.branchId, isNull);
      expect(profile.fullName, isNull);
      expect(profile.isActive, isTrue);
      expect(profile.role, UserRole.receptionist);
    });

    test('maps is_active = false', () {
      final profile = ProfileMapper.fromMap({
        'id': 'u1',
        'role': 'manager',
        'is_active': false,
      });
      expect(profile.isActive, isFalse);
    });

    test('rejects unknown roles with a typed failure', () {
      expect(
        () => ProfileMapper.fromMap({'id': 'u1', 'role': 'superadmin'}),
        throwsA(isA<ValidationFailure>()),
      );
    });
  });
}
