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
                    required email,
                    required phone,
                    required role,
                    required branchId,
                  }) {
                    _invite(
                      fullName: fullName,
                      email: email!,
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
    required String email,
    required UserRole role,
    required String? branchId,
  }) async {
    setState(() => _errorMessage = null);
    try {
      await ref
          .read(employeesControllerProvider.notifier)
          .invite(
            fullName: fullName,
            email: email,
            role: role,
            branchId: branchId,
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
