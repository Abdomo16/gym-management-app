import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_details_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_controller.dart';
import 'package:gym_management_app/features/employees/presentation/widgets/employee_form.dart';

class EditEmployeeScreen extends ConsumerWidget {
  const EditEmployeeScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailsProvider(employeeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Edit employee')),
      body: employeeAsync.when(
        loading: () => const AppLoading(label: 'Loading employee…'),
        error: (error, stackTrace) => AppErrorState(
          failure: error is AppFailure ? error : null,
          message: error is AppFailure
              ? null
              : 'Could not load employee details.',
          onRetry: () => ref.invalidate(employeeDetailsProvider(employeeId)),
        ),
        data: (employee) => _EditEmployeeForm(employee: employee),
      ),
    );
  }
}

class _EditEmployeeForm extends ConsumerStatefulWidget {
  const _EditEmployeeForm({required this.employee});

  final Employee employee;

  @override
  ConsumerState<_EditEmployeeForm> createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends ConsumerState<_EditEmployeeForm> {
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final busy =
        ref.watch(employeesControllerProvider) == EmployeeActionStatus.busy;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: EmployeeForm(
            initial: widget.employee,
            submitLabel: 'Save changes',
            busy: busy,
            serverError: _errorMessage,
            onSubmit:
                ({
                  required fullName,
                  required phone,
                  required role,
                  required branchId,
                }) {
                  _save(
                    fullName: fullName,
                    phone: phone,
                    role: role,
                    branchId: branchId,
                  );
                },
          ),
        ),
      ),
    );
  }

  Future<void> _save({
    required String fullName,
    required String? phone,
    required UserRole role,
    required String? branchId,
  }) async {
    setState(() => _errorMessage = null);
    try {
      await ref
          .read(employeesControllerProvider.notifier)
          .update(
            id: widget.employee.id,
            fullName: fullName,
            phone: phone,
            role: role,
            branchId: branchId,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Employee updated.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } on AppFailure catch (error) {
      if (mounted) setState(() => _errorMessage = error.message);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = 'Unable to save changes.');
    }
  }
}
