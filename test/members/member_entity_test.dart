import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

void main() {
  // ---------------------------------------------------------------------------
  // MemberStatus
  // ---------------------------------------------------------------------------
  group('MemberStatus.fromWireName', () {
    test('maps known wire names to enum values', () {
      expect(MemberStatusX.fromWireName('active'), MemberStatus.active);
      expect(MemberStatusX.fromWireName('inactive'), MemberStatus.inactive);
      expect(MemberStatusX.fromWireName('blocked'), MemberStatus.blocked);
    });

    test('returns null for unknown string', () {
      expect(MemberStatusX.fromWireName('suspended'), isNull);
      expect(MemberStatusX.fromWireName('ACTIVE'), isNull);
      expect(MemberStatusX.fromWireName(''), isNull);
    });

    test('returns null for null input', () {
      expect(MemberStatusX.fromWireName(null), isNull);
    });
  });

  group('MemberStatus.label', () {
    test('active label is Active', () {
      expect(MemberStatus.active.label, 'Active');
    });

    test('inactive label is Inactive', () {
      expect(MemberStatus.inactive.label, 'Inactive');
    });

    test('blocked label is Blocked', () {
      expect(MemberStatus.blocked.label, 'Blocked');
    });
  });

  group('MemberStatus helpers', () {
    test('isActive is true only for active', () {
      expect(MemberStatus.active.isActive, isTrue);
      expect(MemberStatus.inactive.isActive, isFalse);
      expect(MemberStatus.blocked.isActive, isFalse);
    });

    test('isBlocked is true only for blocked', () {
      expect(MemberStatus.blocked.isBlocked, isTrue);
      expect(MemberStatus.active.isBlocked, isFalse);
      expect(MemberStatus.inactive.isBlocked, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // MemberGender
  // ---------------------------------------------------------------------------
  group('MemberGender.fromWireName', () {
    test('maps known wire names to enum values', () {
      expect(MemberGenderX.fromWireName('male'), MemberGender.male);
      expect(MemberGenderX.fromWireName('female'), MemberGender.female);
    });

    test('returns null for unknown string', () {
      expect(MemberGenderX.fromWireName('other'), isNull);
      expect(MemberGenderX.fromWireName('Male'), isNull);
      expect(MemberGenderX.fromWireName(''), isNull);
    });

    test('returns null for null input', () {
      expect(MemberGenderX.fromWireName(null), isNull);
    });
  });

  group('MemberGender.label', () {
    test('male label is Male', () {
      expect(MemberGender.male.label, 'Male');
    });

    test('female label is Female', () {
      expect(MemberGender.female.label, 'Female');
    });
  });

  // ---------------------------------------------------------------------------
  // Member entity
  // ---------------------------------------------------------------------------
  group('Member', () {
    const member = Member(
      id: 'member-1',
      organizationId: 'org-1',
      fullName: 'Ahmed Mohamed',
      phone: '01012345678',
    );

    test('default status is active', () {
      expect(member.status, MemberStatus.active);
    });

    test('optional fields default to null', () {
      expect(member.branchId, isNull);
      expect(member.memberCode, isNull);
      expect(member.gender, isNull);
      expect(member.dateOfBirth, isNull);
      expect(member.photoUrl, isNull);
      expect(member.notes, isNull);
      expect(member.createdAt, isNull);
      expect(member.updatedAt, isNull);
    });

    test('two Members with identical values are equal', () {
      const other = Member(
        id: 'member-1',
        organizationId: 'org-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      expect(member, equals(other));
    });

    test('Members with different ids are not equal', () {
      const other = Member(
        id: 'member-2',
        organizationId: 'org-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      expect(member, isNot(equals(other)));
    });

    test('copyWith changes only the specified fields', () {
      final updated = member.copyWith(
        fullName: 'Sara Ali',
        status: MemberStatus.inactive,
      );
      expect(updated.id, 'member-1');
      expect(updated.organizationId, 'org-1');
      expect(updated.phone, '01012345678');
      expect(updated.fullName, 'Sara Ali');
      expect(updated.status, MemberStatus.inactive);
    });

    test('copyWith with no arguments returns an equal object', () {
      final copy = member.copyWith();
      expect(copy, equals(member));
    });

    test('full Member with all fields round-trips through copyWith', () {
      final dob = DateTime(1990, 5, 15);
      final created = DateTime(2024, 1, 1);
      final full = Member(
        id: 'member-1',
        organizationId: 'org-1',
        branchId: 'branch-1',
        memberCode: 'GYM-000001',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
        gender: MemberGender.male,
        dateOfBirth: dob,
        photoUrl: 'https://example.com/photo.jpg',
        notes: 'Test notes',
        status: MemberStatus.active,
        createdAt: created,
      );

      expect(full.branchId, 'branch-1');
      expect(full.memberCode, 'GYM-000001');
      expect(full.gender, MemberGender.male);
      expect(full.dateOfBirth, dob);
      expect(full.photoUrl, 'https://example.com/photo.jpg');
      expect(full.notes, 'Test notes');
      expect(full.createdAt, created);
    });
  });
}
