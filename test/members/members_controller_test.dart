import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

import '../helpers/fake_members_repository.dart';

ProviderContainer makeContainer(FakeMembersRepository repo) {
  final container = ProviderContainer(
    overrides: [membersRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final testMember = FakeMembersRepository.makeTestMember();

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------
  group('MembersController – initial state', () {
    test('initial state is idle', () {
      final container = makeContainer(FakeMembersRepository());
      expect(
        container.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // createMember
  // ---------------------------------------------------------------------------
  group('MembersController.createMember', () {
    test('returns the created member on success', () async {
      final container = makeContainer(FakeMembersRepository());
      final result = await container
          .read(membersControllerProvider.notifier)
          .createMember(
            organizationId: 'org-1',
            fullName: 'Ahmed Mohamed',
            phone: '01012345678',
          );
      expect(result, isA<Member>());
      expect(result.fullName, 'Ahmed Mohamed');
    });

    test('state returns to idle after successful createMember', () async {
      final container = makeContainer(FakeMembersRepository());
      await container
          .read(membersControllerProvider.notifier)
          .createMember(
            organizationId: 'org-1',
            fullName: 'Ahmed Mohamed',
            phone: '01012345678',
          );
      expect(
        container.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });

    test('state returns to idle after createMember failure', () async {
      final container = makeContainer(
        FakeMembersRepository(throwDuplicatePhone: true),
      );
      await expectLater(
        container.read(membersControllerProvider.notifier).createMember(
          organizationId: 'org-1',
          fullName: 'Ahmed Mohamed',
          phone: '01012345678',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        container.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });

    test('SupabaseFailure is rethrown to the caller', () async {
      final container = makeContainer(
        FakeMembersRepository(throwDuplicatePhone: true),
      );
      await expectLater(
        container.read(membersControllerProvider.notifier).createMember(
          organizationId: 'org-1',
          fullName: 'Ahmed Mohamed',
          phone: '01012345678',
        ),
        throwsA(
          isA<SupabaseFailure>().having(
            (f) => f.message,
            'message',
            contains('phone number'),
          ),
        ),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateMember
  // ---------------------------------------------------------------------------
  group('MembersController.updateMember', () {
    test('returns the updated member on success', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [testMember]),
      );
      final result = await container
          .read(membersControllerProvider.notifier)
          .updateMember(
            id: 'member-1',
            fullName: 'Ahmed Updated',
            phone: '01099999999',
          );
      expect(result.id, 'member-1');
      expect(result.fullName, 'Ahmed Updated');
    });

    test('state returns to idle after successful updateMember', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [testMember]),
      );
      await container
          .read(membersControllerProvider.notifier)
          .updateMember(
            id: 'member-1',
            fullName: 'Ahmed Updated',
            phone: '01099999999',
          );
      expect(
        container.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });

    test('state returns to idle after updateMember failure', () async {
      // throwOnGet causes getMemberById to fail; updateMember in the fake
      // does not use getMemberById, so we use a custom error repo instead.
      final errorContainer = makeContainer(_ThrowingRepo());
      await expectLater(
        errorContainer
            .read(membersControllerProvider.notifier)
            .updateMember(
              id: 'member-1',
              fullName: 'Ahmed Mohamed',
              phone: '01012345678',
            ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        errorContainer.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });
  });

  // ---------------------------------------------------------------------------
  // updateMemberStatus
  // ---------------------------------------------------------------------------
  group('MembersController.updateMemberStatus', () {
    test('returns member with the new status on success', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [testMember]),
      );
      final result = await container
          .read(membersControllerProvider.notifier)
          .updateMemberStatus(
            id: 'member-1',
            status: MemberStatus.inactive,
          );
      expect(result.status, MemberStatus.inactive);
    });

    test('state returns to idle after successful updateMemberStatus', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [testMember]),
      );
      await container
          .read(membersControllerProvider.notifier)
          .updateMemberStatus(
            id: 'member-1',
            status: MemberStatus.blocked,
          );
      expect(
        container.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });

    test('state returns to idle after updateMemberStatus failure', () async {
      final errorContainer = makeContainer(_ThrowingRepo());
      await expectLater(
        errorContainer
            .read(membersControllerProvider.notifier)
            .updateMemberStatus(
              id: 'member-1',
              status: MemberStatus.inactive,
            ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        errorContainer.read(membersControllerProvider),
        MemberActionStatus.idle,
      );
    });

    test('SupabaseFailure is rethrown to the caller', () async {
      final errorContainer = makeContainer(_ThrowingRepo());
      await expectLater(
        errorContainer
            .read(membersControllerProvider.notifier)
            .updateMemberStatus(
              id: 'member-1',
              status: MemberStatus.inactive,
            ),
        throwsA(isA<AppFailure>()),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: repository that always throws on mutations
// ---------------------------------------------------------------------------
class _ThrowingRepo extends FakeMembersRepository {
  _ThrowingRepo() : super();

  @override
  Future<Member> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    throw const SupabaseFailure(message: 'Simulated server error.');
  }

  @override
  Future<Member> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    throw const SupabaseFailure(message: 'Simulated server error.');
  }

  @override
  Future<Member> updateMemberStatus({
    required String id,
    required MemberStatus status,
  }) async {
    throw const SupabaseFailure(message: 'Simulated server error.');
  }
}
