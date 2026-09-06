import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/create_member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_members.dart';
import 'package:gym_management_app/features/members/domain/usecases/search_members.dart';
import 'package:gym_management_app/features/members/domain/usecases/update_member.dart';
import 'package:gym_management_app/features/members/domain/usecases/update_member_status.dart';

import '../helpers/fake_members_repository.dart';

void main() {
  // Shared test member used across groups.
  final testMember = FakeMembersRepository.makeTestMember();

  // ---------------------------------------------------------------------------
  // GetMembers
  // ---------------------------------------------------------------------------
  group('GetMembers', () {
    test('returns all members from the repository', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await GetMembers(repo)();
      expect(result, [testMember]);
    });

    test('returns empty list when repository has no members', () async {
      final repo = FakeMembersRepository();
      final result = await GetMembers(repo)();
      expect(result, isEmpty);
    });

    test('respects the limit parameter', () async {
      final members = List.generate(
        10,
        (i) => FakeMembersRepository.makeTestMember(id: 'member-$i'),
      );
      final repo = FakeMembersRepository(members: members);
      final result = await GetMembers(repo)(limit: 3);
      expect(result.length, 3);
    });

    test('propagates repository failures', () async {
      final repo = FakeMembersRepository(throwOnGet: true);
      await expectLater(
        GetMembers(repo)(),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // SearchMembers
  // ---------------------------------------------------------------------------
  group('SearchMembers', () {
    final ahmed = FakeMembersRepository.makeTestMember(
      id: 'member-1',
      fullName: 'Ahmed Mohamed',
      phone: '01012345678',
    );
    final sara = FakeMembersRepository.makeTestMember(
      id: 'member-2',
      fullName: 'Sara Ali',
      phone: '01098765432',
      memberCode: 'GYM-000002',
    );

    test('returns members matching the query by name', () async {
      final repo = FakeMembersRepository(members: [ahmed, sara]);
      final result = await SearchMembers(repo)('Ahmed');
      expect(result, [ahmed]);
      expect(result, isNot(contains(sara)));
    });

    test('returns members matching the query by phone', () async {
      final repo = FakeMembersRepository(members: [ahmed, sara]);
      final result = await SearchMembers(repo)('0109876');
      expect(result, [sara]);
    });

    test('returns members matching the query by member code', () async {
      final repo = FakeMembersRepository(members: [ahmed, sara]);
      final result = await SearchMembers(repo)('GYM-000001');
      expect(result, [ahmed]);
    });

    test('returns empty list when no members match', () async {
      final repo = FakeMembersRepository(members: [ahmed, sara]);
      final result = await SearchMembers(repo)('Khalid');
      expect(result, isEmpty);
    });

    test('search is case-insensitive', () async {
      final repo = FakeMembersRepository(members: [ahmed]);
      final result = await SearchMembers(repo)('ahmed');
      expect(result, [ahmed]);
    });

    test('propagates repository failures', () async {
      final repo = FakeMembersRepository(throwOnGet: true);
      await expectLater(
        SearchMembers(repo)('Ahmed'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // GetMember
  // ---------------------------------------------------------------------------
  group('GetMember', () {
    test('returns the member when found', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await GetMember(repo)('member-1');
      expect(result, testMember);
    });

    test('returns null when member is not found', () async {
      final repo = FakeMembersRepository();
      final result = await GetMember(repo)('unknown-id');
      expect(result, isNull);
    });

    test('propagates repository failures', () async {
      final repo = FakeMembersRepository(throwOnGet: true);
      await expectLater(
        GetMember(repo)('member-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // CreateMember
  // ---------------------------------------------------------------------------
  group('CreateMember', () {
    test('returns the newly created member', () async {
      final repo = FakeMembersRepository();
      final result = await CreateMember(repo)(
        organizationId: 'org-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      expect(result.fullName, 'Ahmed Mohamed');
      expect(result.phone, '01012345678');
      expect(result.organizationId, 'org-1');
    });

    test('passes optional fields through to the repository', () async {
      final repo = FakeMembersRepository();
      final dob = DateTime(1990, 5, 15);
      final result = await CreateMember(repo)(
        organizationId: 'org-1',
        branchId: 'branch-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
        gender: 'male',
        dateOfBirth: dob,
        photoUrl: 'https://example.com/photo.jpg',
        notes: 'Test notes',
      );
      // The fake returns a fixed member; we just verify no exception is thrown
      // and the call completes successfully.
      expect(result, isA<Member>());
    });

    test('propagates SupabaseFailure for duplicate phone', () async {
      final repo = FakeMembersRepository(throwDuplicatePhone: true);
      await expectLater(
        CreateMember(repo)(
          organizationId: 'org-1',
          fullName: 'Ahmed Mohamed',
          phone: '01012345678',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateMember
  // ---------------------------------------------------------------------------
  group('UpdateMember', () {
    test('returns the updated member', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await UpdateMember(repo)(
        id: 'member-1',
        fullName: 'Ahmed Updated',
        phone: '01099999999',
      );
      expect(result.id, 'member-1');
      expect(result.fullName, 'Ahmed Updated');
      expect(result.phone, '01099999999');
    });

    test('preserves unchanged fields', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await UpdateMember(repo)(
        id: 'member-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      expect(result.organizationId, 'org-1');
      expect(result.status, MemberStatus.active);
    });
  });

  // ---------------------------------------------------------------------------
  // UpdateMemberStatus
  // ---------------------------------------------------------------------------
  group('UpdateMemberStatus', () {
    test('returns member with the new status', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await UpdateMemberStatus(repo)(
        id: 'member-1',
        status: MemberStatus.inactive,
      );
      expect(result.id, 'member-1');
      expect(result.status, MemberStatus.inactive);
    });

    test('can set status to blocked', () async {
      final repo = FakeMembersRepository(members: [testMember]);
      final result = await UpdateMemberStatus(repo)(
        id: 'member-1',
        status: MemberStatus.blocked,
      );
      expect(result.status, MemberStatus.blocked);
    });

    test('can reactivate a blocked member', () async {
      final blocked = testMember.copyWith(status: MemberStatus.blocked);
      final repo = FakeMembersRepository(members: [blocked]);
      final result = await UpdateMemberStatus(repo)(
        id: 'member-1',
        status: MemberStatus.active,
      );
      expect(result.status, MemberStatus.active);
    });
  });
}
