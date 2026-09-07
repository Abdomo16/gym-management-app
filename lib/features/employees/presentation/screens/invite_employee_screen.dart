import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_controller.dart';
import 'package:gym_management_app/features/employees/presentation/widgets/employee_form.dart';

class InviteEmployeeScreen extends ConsumerStatefulWidget {
  const InviteEmployeeScreen({super.key});

  @override
  ConsumerState<InviteEmployeeScreen> createState() =>
      _InviteEmployeeScreenState();
}

class _InviteEmployeeScreenState extends ConsumerState<InviteEmployeeScreen> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final busy =
        ref.watch(employeesControllerProvider) == EmployeeActionStatus.busy;
    return Scaffold(
      appBar: AppBar(title: const Text('Invite employee')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: EmployeeForm(
              submitLabel: 'Send invitation',
              busy: busy,
              serverError: _errorMessage,
              onSubmit:
                  ({
                    required fullName,
                    required phone,
                    required role,
                    required branchId,
                  }) {
                    _invite(
                      fullName: fullName,
                      phone: phone,
                      role: role,
                      branchId: branchId,
                    );
                  },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _invite({
    required String fullName,
    String? phone,
    required UserRole role,
    required String? branchId,
  }) async {
    setState(() => _errorMessage = null);
    try {
      final invitation = await ref
          .read(employeesControllerProvider.notifier)
          .invite(
            fullName: fullName,
            phone: phone,
            role: role,
            branchId: branchId,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invitation created'),
          content: SelectableText(
            'Share this invitation token with the employee:\n\n'
            '${invitation.token}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee invitation created.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on AppFailure catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (error) {
      if (mounted) {
        setState(() => _errorMessage = 'Unable to create the invitation.');
      }
    }
  }
}
