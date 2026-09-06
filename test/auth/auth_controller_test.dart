import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

import '../helpers/auth_fixtures.dart';
import '../helpers/fake_auth_repository.dart';

Future<AuthState> resolveAuth(ProviderContainer container) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (DateTime.now().isBefore(deadline)) {
    final state = container.read(authControllerProvider);
    if (state is! AuthInitializing) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Auth state never resolved');
}

ProviderContainer makeContainer(FakeAuthRepository repository) {
  final container = ProviderContainer(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('session restoration', () {
    test('no session → unauthenticated', () async {
      final container = makeContainer(FakeAuthRepository());
      final state = await resolveAuth(container);
      expect(state, isA<AuthUnauthenticated>());
    });

    test('valid active profile → authenticated', () async {
      final container = makeContainer(
        FakeAuthRepository(initialRestore: authenticatedState()),
      );
      final state = await resolveAuth(container);
      expect(state, isA<AuthAuthenticated>());
      final user = (state as AuthAuthenticated).user;
      expect(user.email, 'owner@gym.test');
      expect(user.organizationId, 'org-1');
      expect(user.isActive, isTrue);
    });

    test('missing profile → needs onboarding', () async {
      final container = makeContainer(
        FakeAuthRepository(
          initialRestore: const AuthNeedsOnboarding(email: 'x@gym.test'),
        ),
      );
      final state = await resolveAuth(container);
      expect(state, isA<AuthNeedsOnboarding>());
    });

    test('inactive profile → disabled', () async {
      final container = makeContainer(
        FakeAuthRepository(
          initialRestore: const AuthDisabled(email: 'x@gym.test'),
        ),
      );
      final state = await resolveAuth(container);
      expect(state, isA<AuthDisabled>());
    });

    test('restoration failure → error state', () async {
      final container = makeContainer(
        FakeAuthRepository(restoreError: const NetworkFailure()),
      );
      final state = await resolveAuth(container);
      expect(state, isA<AuthError>());
      expect((state as AuthError).failure, isA<NetworkFailure>());
    });
  });

  group('sign in / sign out', () {
    test('sign-in triggers restoration into authenticated', () async {
      final repository = FakeAuthRepository();
      repository.setRestoreResult(authenticatedState());
      final container = makeContainer(repository);

      await resolveAuth(container);
      await container
          .read(authControllerProvider.notifier)
          .signIn(email: 'owner@gym.test', password: 'password');

      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while (DateTime.now().isBefore(deadline)) {
        final state = container.read(authControllerProvider);
        if (state is AuthAuthenticated) {
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      fail('Sign-in never reached authenticated');
    });

    test('sign-in failure surfaces a typed failure', () async {
      final repository = FakeAuthRepository(
        signInError: const AuthFailure(message: 'Invalid email or password.'),
      );
      final container = makeContainer(repository);
      await resolveAuth(container);

      await expectLater(
        container.read(authControllerProvider.notifier).signIn(
          email: 'owner@gym.test',
          password: 'wrong',
        ),
        throwsA(isA<AuthFailure>()),
      );
      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    });

    test('sign-out returns to unauthenticated', () async {
      final repository = FakeAuthRepository(
        initialRestore: authenticatedState(),
      );
      final container = makeContainer(repository);
      await resolveAuth(container);

      await container.read(authControllerProvider.notifier).signOut();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(container.read(authControllerProvider), isA<AuthUnauthenticated>());
    });
  });

  group('onboarding and invitations', () {
    test('createOrganization transitions to authenticated', () async {
      final container = makeContainer(
        FakeAuthRepository(
          initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
        ),
      );
      await resolveAuth(container);

      await container.read(authControllerProvider.notifier).createOrganization(
        orgName: 'FitZone',
        ownerFullName: 'Alex Owner',
        timezone: 'Africa/Cairo',
      );

      final state = container.read(authControllerProvider);
      expect(state, isA<AuthAuthenticated>());
      expect((state as AuthAuthenticated).user.fullName, 'Alex Owner');
    });

    test('createOrganization failure propagates and keeps state', () async {
      final repository = FakeAuthRepository(
        initialRestore: const AuthNeedsOnboarding(email: 'owner@gym.test'),
      );
      repository.createOrganizationError = const SupabaseFailure(
        message: 'Could not create your gym. Please try again.',
      );
      final container = makeContainer(repository);
      await resolveAuth(container);

      await expectLater(
        container.read(authControllerProvider.notifier).createOrganization(
          orgName: 'FitZone',
          ownerFullName: 'Alex Owner',
          timezone: 'Africa/Cairo',
        ),
        throwsA(isA<SupabaseFailure>()),
      );
      expect(
        container.read(authControllerProvider),
        isA<AuthNeedsOnboarding>(),
      );
    });

    test('acceptInvitation transitions to authenticated', () async {
      final container = makeContainer(
        FakeAuthRepository(
          initialRestore: const AuthNeedsOnboarding(email: 'e@gym.test'),
        ),
      );
      await resolveAuth(container);

      await container
          .read(authControllerProvider.notifier)
          .acceptInvitation('invite-abc');

      expect(
        container.read(authControllerProvider),
        isA<AuthAuthenticated>(),
      );
    });
  });
}
