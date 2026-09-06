import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_providers.dart';
import 'package:gym_management_app/features/auth/presentation/widgets/auth_error_message.dart';

/// Accepts an employee invitation using the token carried in the URL
/// (`?token=...`).
///
/// On success the router guard moves the employee into the authenticated
/// application; on failure an inline error with a retry is shown.
class InvitationAcceptScreen extends ConsumerStatefulWidget {
  const InvitationAcceptScreen({super.key});

  @override
  ConsumerState<InvitationAcceptScreen> createState() =>
      _InvitationAcceptScreenState();
}

class _InvitationAcceptScreenState extends ConsumerState<InvitationAcceptScreen> {
  bool _isBusy = true;
  String? _errorMessage;
  String? _token;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // GoRouterState depends on inherited widgets, so it may only be read
    // after the element is mounted.
    if (!_started) {
      _started = true;
      _token = GoRouterState.of(context).uri.queryParameters['token'];
      unawaited(_accept());
    }
  }

  Future<void> _accept() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _errorMessage = 'This invitation link is invalid or missing its '
              'token. Please ask your gym administrator for a new link.';
        });
      }
      return;
    }
    setState(() {
      _isBusy = true;
      _errorMessage = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).acceptInvitation(token);
      // The router guard redirects into the application on success.
    } on AppFailure catch (error) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _errorMessage = error.message;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isBusy = false;
          _errorMessage = ExceptionMapper.map(error).message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_isBusy) ...[
                  const AppLoading(label: 'Accepting your invitation…'),
                ] else ...[
                  Text(
                    'Invitation',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    AuthErrorMessage(message: _errorMessage!),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Try again',
                      variant: AppButtonVariant.outline,
                      expanded: true,
                      onPressed: _accept,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
