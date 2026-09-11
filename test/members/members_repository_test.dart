import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

import '../helpers/fake_members_repository.dart';

void main() {
  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------
  FakeMembersRepository makeRepo({
    List<Member> members = const [],
    bool throwDuplicatePhone = false,
    bool throwOnGet = false,
  }) {
    return FakeMembersRepository(
      members: members,
      throwDuplicatePhone: throwDuplicatePhone,
      throwOnGet: throwOnGet,
    );
  }

  final member1 = FakeMembersRepository.makeTestMember(id: 'member-1');
  final member2 = FakeMembersRepository.makeTestMember(
    id: 'member-2',
    fullName: 'Sara Ali',
    phone: '01098765432',
    memberCode: 'GYM-000002',
  );

  // ---------------------------------------------------------------------------
  // getMembers
  // ---------------------------------------------------------------------------
  group('MembersRepository.getMembers', () {
    test('returns all members', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.getMembers();
      expect(result, hasLength(2));
      expect(result, containsAll([member1, member2]));
    });

    test('returns empty list when no members exist', () async {
      final repo = makeRepo();
      final result = await repo.getMembers();
      expect(result, isEmpty);
    });

    test('respects the limit parameter', () async {
      final many = List.generate(
        10,
        (i) => FakeMembersRepository.makeTestMember(id: 'member-$i'),
      );
      final repo = makeRepo(members: many);
      final result = await repo.getMembers(limit: 4);
      expect(result.length, 4);
    });

    test('offset pages past the first slice', () async {
      final many = List.generate(
        10,
        (i) => FakeMembersRepository.makeTestMember(id: 'member-$i'),
      );
      final repo = makeRepo(members: many);
      final page = await repo.getMembers(limit: 4, offset: 6);
      expect(page, hasLength(4));
      expect(page.map((m) => m.id), ['member-6', 'member-7', 'member-8', 'member-9']);
      final tail = await repo.getMembers(limit: 4, offset: 8);
      expect(tail, hasLength(2));
    });

    test('throws SupabaseFailure when throwOnGet is true', () async {
      final repo = makeRepo(throwOnGet: true);
      await expectLater(
        repo.getMembers(),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // searchMembers
  // ---------------------------------------------------------------------------
  group('MembersRepository.searchMembers', () {
    test('returns members matching by full name', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.searchMembers('Ahmed');
      expect(result, [member1]);
    });

    test('returns members matching by phone', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.searchMembers('0109876');
      expect(result, [member2]);
    });

    test('returns members matching by member code', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.searchMembers('GYM-000002');
      expect(result, [member2]);
    });

    test('returns empty list when no match', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.searchMembers('Khalid');
      expect(result, isEmpty);
    });

    test('search is case-insensitive', () async {
      final repo = makeRepo(members: [member1]);
      final result = await repo.searchMembers('ahmed');
      expect(result, [member1]);
    });

    test('throws SupabaseFailure when throwOnGet is true', () async {
      final repo = makeRepo(throwOnGet: true);
      await expectLater(
        repo.searchMembers('Ahmed'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // getMemberById
  // ---------------------------------------------------------------------------
  group('MembersRepository.getMemberById', () {
    test('returns the member when found', () async {
      final repo = makeRepo(members: [member1, member2]);
      final result = await repo.getMemberById('member-1');
      expect(result, member1);
    });

    test('returns null when member is not found', () async {
      final repo = makeRepo(members: [member1]);
      final result = await repo.getMemberById('unknown-id');
      expect(result, isNull);
    });

    test('throws SupabaseFailure when throwOnGet is true', () async {
      final repo = makeRepo(throwOnGet: true);
      await expectLater(
        repo.getMemberById('member-1'),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createMember
  // ---------------------------------------------------------------------------
  group('MembersRepository.createMember', () {
    test('returns the created member', () async {
      final repo = makeRepo();
      final result = await repo.createMember(
        organizationId: 'org-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      expect(result.fullName, 'Ahmed Mohamed');
      expect(result.phone, '01012345678');
      expect(result.organizationId, 'org-1');
    });

    test('adds the member to the internal list', () async {
      final repo = makeRepo();
      await repo.createMember(
        organizationId: 'org-1',
        fullName: 'Ahmed Mohamed',
        phone: '01012345678',
      );
      final all = await repo.getMembers();
      expect(all, hasLength(1));
    });

    test('throws SupabaseFailure for duplicate phone', () async {
      final repo = makeRepo(throwDuplicatePhone: true);
      await expectLater(
        repo.createMember(
          organizationId: 'org-1',
          fullName: 'Ahmed Mohamed',
          phone: '01012345678',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateMember
  // ---------------------------------------------------------------------------
  group('MembersRepository.updateMember', () {
    test('returns the updated member with new values', () async {
      final repo = makeRepo(members: [member1]);
      final result = await repo.updateMember(
        id: 'member-1',
        fullName: 'Ahmed Updated',
        phone: '01099999999',
      );
      expect(result.id, 'member-1');
      expect(result.fullName, 'Ahmed Updated');
      expect(result.phone, '01099999999');
    });

    test('updates the member in the internal list', () async {
      final repo = makeRepo(members: [member1]);
      await repo.updateMember(
        id: 'member-1',
        fullName: 'Ahmed Updated',
        phone: '01099999999',
      );
      final found = await repo.getMemberById('member-1');
      expect(found?.fullName, 'Ahmed Updated');
    });
  });

  // ---------------------------------------------------------------------------
  // updateMemberStatus
  // ---------------------------------------------------------------------------
  group('MembersRepository.updateMemberStatus', () {
    test('returns member with the new status', () async {
      final repo = makeRepo(members: [member1]);
      final result = await repo.updateMemberStatus(
        id: 'member-1',
        status: MemberStatus.inactive,
      );
      expect(result.status, MemberStatus.inactive);
    });

    test('updates the status in the internal list', () async {
      final repo = makeRepo(members: [member1]);
      await repo.updateMemberStatus(
        id: 'member-1',
        status: MemberStatus.blocked,
      );
      final found = await repo.getMemberById('member-1');
      expect(found?.status, MemberStatus.blocked);
    });

    test('can cycle through all statuses', () async {
      final repo = makeRepo(members: [member1]);

      await repo.updateMemberStatus(id: 'member-1', status: MemberStatus.inactive);
      expect((await repo.getMemberById('member-1'))?.status, MemberStatus.inactive);

      await repo.updateMemberStatus(id: 'member-1', status: MemberStatus.blocked);
      expect((await repo.getMemberById('member-1'))?.status, MemberStatus.blocked);

      await repo.updateMemberStatus(id: 'member-1', status: MemberStatus.active);
      expect((await repo.getMemberById('member-1'))?.status, MemberStatus.active);
    });
  });

  // ---------------------------------------------------------------------------
  // getOrganizationBranches
  // ---------------------------------------------------------------------------
  group('MembersRepository.getOrganizationBranches', () {
    test('returns the list of branches', () async {
      final repo = makeRepo();
      final branches = await repo.getOrganizationBranches('org-1');
      expect(branches, hasLength(1));
      expect(branches.first.id, 'branch-1');
      expect(branches.first.name, 'Main Branch');
    });
  });
}
