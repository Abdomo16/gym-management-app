import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/data/mappers/member_mapper.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

const _fullMap = <String, dynamic>{
  'id': 'member-1',
  'organization_id': 'org-1',
  'branch_id': 'branch-1',
  'member_code': 'GYM-000001',
  'full_name': 'Ahmed Mohamed',
  'phone': '01012345678',
  'gender': 'male',
  'date_of_birth': '1990-05-15',
  'photo_url': 'https://example.com/photo.jpg',
  'notes': 'Test notes',
  'status': 'active',
  'created_at': '2024-01-01T00:00:00.000Z',
  'updated_at': '2024-01-02T00:00:00.000Z',
};

void main() {
  group('MemberMapper.fromMap', () {
    test('maps all fields from a complete map', () {
      final member = MemberMapper.fromMap(_fullMap);

      expect(member.id, 'member-1');
      expect(member.organizationId, 'org-1');
      expect(member.branchId, 'branch-1');
      expect(member.memberCode, 'GYM-000001');
      expect(member.fullName, 'Ahmed Mohamed');
      expect(member.phone, '01012345678');
      expect(member.gender, MemberGender.male);
      expect(member.photoUrl, 'https://example.com/photo.jpg');
      expect(member.notes, 'Test notes');
      expect(member.status, MemberStatus.active);
    });

    test('maps inactive and blocked status correctly', () {
      final inactive = MemberMapper.fromMap({..._fullMap, 'status': 'inactive'});
      expect(inactive.status, MemberStatus.inactive);

      final blocked = MemberMapper.fromMap({..._fullMap, 'status': 'blocked'});
      expect(blocked.status, MemberStatus.blocked);
    });

    test('maps female gender correctly', () {
      final member = MemberMapper.fromMap({..._fullMap, 'gender': 'female'});
      expect(member.gender, MemberGender.female);
    });

    test('parses date_of_birth correctly', () {
      final member = MemberMapper.fromMap(_fullMap);
      expect(member.dateOfBirth, isNotNull);
      expect(member.dateOfBirth!.year, 1990);
      expect(member.dateOfBirth!.month, 5);
      expect(member.dateOfBirth!.day, 15);
    });

    test('parses created_at and updated_at correctly', () {
      final member = MemberMapper.fromMap(_fullMap);
      expect(member.createdAt, isNotNull);
      expect(member.createdAt!.year, 2024);
      expect(member.createdAt!.month, 1);
      expect(member.createdAt!.day, 1);

      expect(member.updatedAt, isNotNull);
      expect(member.updatedAt!.year, 2024);
      expect(member.updatedAt!.month, 1);
      expect(member.updatedAt!.day, 2);
    });

    test('maps null optional fields to null', () {
      final minimalMap = <String, dynamic>{
        'id': 'member-2',
        'organization_id': 'org-1',
        'full_name': 'Sara Ali',
        'phone': '01098765432',
        'status': 'active',
        'branch_id': null,
        'member_code': null,
        'gender': null,
        'date_of_birth': null,
        'photo_url': null,
        'notes': null,
        'created_at': null,
        'updated_at': null,
      };

      final member = MemberMapper.fromMap(minimalMap);

      expect(member.branchId, isNull);
      expect(member.memberCode, isNull);
      expect(member.gender, isNull);
      expect(member.dateOfBirth, isNull);
      expect(member.photoUrl, isNull);
      expect(member.notes, isNull);
      expect(member.createdAt, isNull);
      expect(member.updatedAt, isNull);
    });

    test('missing optional fields default gracefully', () {
      final sparseMap = <String, dynamic>{
        'id': 'member-3',
        'organization_id': 'org-1',
        'status': 'active',
      };

      final member = MemberMapper.fromMap(sparseMap);

      expect(member.fullName, '');
      expect(member.phone, '');
      expect(member.branchId, isNull);
      expect(member.memberCode, isNull);
    });

    test('empty full_name defaults to empty string', () {
      final member = MemberMapper.fromMap({..._fullMap, 'full_name': null});
      expect(member.fullName, '');
    });

    test('empty phone defaults to empty string', () {
      final member = MemberMapper.fromMap({..._fullMap, 'phone': null});
      expect(member.phone, '');
    });

    test('throws ValidationFailure for null status', () {
      final badMap = <String, dynamic>{..._fullMap, 'status': null};
      expect(
        () => MemberMapper.fromMap(badMap),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('throws ValidationFailure for unknown status string', () {
      final badMap = <String, dynamic>{..._fullMap, 'status': 'suspended'};
      expect(
        () => MemberMapper.fromMap(badMap),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('unknown gender string maps to null (not an error)', () {
      final member = MemberMapper.fromMap({..._fullMap, 'gender': 'other'});
      expect(member.gender, isNull);
    });

    test('empty date string maps to null', () {
      final member = MemberMapper.fromMap({..._fullMap, 'date_of_birth': ''});
      expect(member.dateOfBirth, isNull);
    });

    test('malformed date string maps to null', () {
      final member = MemberMapper.fromMap({
        ..._fullMap,
        'date_of_birth': 'not-a-date',
      });
      expect(member.dateOfBirth, isNull);
    });
  });
}
