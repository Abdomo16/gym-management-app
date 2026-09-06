import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/check_in_controller.dart';
import 'package:gym_management_app/features/auth/domain/entities/organization_context.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

import '../helpers/fake_attendance_repository.dart';

ProviderContainer makeContainer(FakeAttendanceRepository repository) {
  final context = OrganizationContext(
    organizationId: 'org-from-profile',
    branchId: 'branch-from-profile',
    role: UserRole.receptionist,
    profile: const UserProfile(
      id: 'profile-1',
      organizationId: 'org-from-profile',
      branchId: 'branch-from-profile',
      role: UserRole.receptionist,
    ),
  );
  final container = ProviderContainer(
    overrides: [
      attendanceRepositoryProvider.overrideWithValue(repository),
      organizationContextProvider.overrideWithValue(context),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final member = Member(
    id: 'member-1',
    organizationId: 'member-org-that-is-not-trusted',
    branchId: 'member-branch-that-is-not-trusted',
    fullName: 'Ahmed Mohamed',
    phone: '01012345678',
  );

  test('checks in using the authenticated organization and branch context', () async {
    final repository = FakeAttendanceRepository();
    final container = makeContainer(repository);

    final result = await container
        .read(checkInControllerProvider.notifier)
        .checkIn(member);

    expect(result.organizationId, 'org-from-profile');
    expect(result.branchId, 'branch-from-profile');
    expect(repository.records, hasLength(1));
    expect(
      container.read(checkInControllerProvider),
      CheckInActionStatus.idle,
    );
  });

  test('maps a duplicate check-in failure without reporting success', () async {
    final repository = FakeAttendanceRepository(throwOnCheckIn: true);
    final container = makeContainer(repository);

    await expectLater(
      container.read(checkInControllerProvider.notifier).checkIn(member),
      throwsA(isA<SupabaseFailure>()),
    );

    expect(repository.records, isEmpty);
    expect(
      container.read(checkInControllerProvider),
      CheckInActionStatus.idle,
    );
  });
}