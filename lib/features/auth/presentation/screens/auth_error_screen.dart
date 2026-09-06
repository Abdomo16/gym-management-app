import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';

/// Shown when session restoration fails (e.g. a network hiccup at startup).
///
/// Offers a retry that re-runs restoration. This screen is only reachable
/// while the auth state is [AuthError].
class AuthErrorScreen extends ConsumerWidget {
  const AuthErrorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failure = ref.watch(authControllerProvider) as AuthError;
    return Scaffold(
      body: AppErrorState(
        failure: failure.failure,
        onRetry: () {
          ref.read(authControllerProvider.notifier).retry();
        },
      ),
    );
  }
}
