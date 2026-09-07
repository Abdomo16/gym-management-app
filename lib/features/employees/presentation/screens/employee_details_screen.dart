import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_card.dart';
import 'package:gym_management_app/core/widgets/app_dialog.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employee_details_provider.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_controller.dart';
import 'package:gym_management_app/features/employees/presentation/widgets/employee_status_badge.dart';

class EmployeeDetailsScreen extends ConsumerWidget {
  const EmployeeDetailsScreen({super.key, required this.employeeId});

  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeAsync = ref.watch(employeeDetailsProvider(employeeId));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee details'),
        actions: [
          employeeAsync.whenOrNull(
                data: (employee) => IconButton(
                  tooltip: 'Edit employee',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () =>
                      context.push(RoutePaths.employeeEdit(employee.id)),
                ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: employeeAsync.when(
        loading: () => const AppLoading(label: 'Loading employee…'),
        error: (error, stackTrace) => AppErrorState(
          failure: error is AppFailure ? error : null,
          message: error is AppFailure
              ? null
              : 'Could not load employee details.',
          onRetry: () => ref.invalidate(employeeDetailsProvider(employeeId)),
        ),
        data: (employee) => _EmployeeDetailsBody(employee: employee),
      ),
    );
  }
}

class _EmployeeDetailsBody extends ConsumerWidget {
  const _EmployeeDetailsBody({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy =
        ref.watch(employeesControllerProvider) == EmployeeActionStatus.busy;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _EmployeeHero(employee: employee),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Account information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: 'Full name', value: employee.fullName),
                    _InfoRow(
                      label: 'Email',
                      value: employee.email ?? 'Not available',
                    ),
                    _InfoRow(
                      label: 'Phone',
                      value: employee.phone ?? 'Not provided',
                    ),
                    _InfoRow(label: 'Role', value: employee.role.label),
                    _InfoRow(
                      label: 'Branch',
                      value: employee.branchName ?? 'Not assigned',
                    ),
                    if (employee.createdAt != null)
                      _InfoRow(
                        label: 'Created',
                        value: _formatDate(employee.createdAt!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: employee.isActive
                    ? 'Deactivate employee'
                    : 'Activate employee',
                icon: employee.isActive
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                variant: employee.isActive
                    ? AppButtonVariant.danger
                    : AppButtonVariant.primary,
                busy: busy,
                expanded: true,
                onPressed: busy
                    ? null
                    : () => _changeActiveState(context, ref, employee),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _changeActiveState(
    BuildContext context,
    WidgetRef ref,
    Employee employee,
  ) async {
    final nextState = !employee.isActive;
    final confirmed = await AppDialog.confirm(
      context: context,
      title: nextState ? 'Activate employee?' : 'Deactivate employee?',
      message: nextState
          ? 'This employee will be able to use the application again.'
          : 'This employee will no longer be able to use the application.',
      confirmLabel: nextState ? 'Activate' : 'Deactivate',
      confirmVariant: nextState
          ? AppButtonVariant.primary
          : AppButtonVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref
          .read(employeesControllerProvider.notifier)
          .setActive(id: employee.id, isActive: nextState);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextState ? 'Employee activated.' : 'Employee deactivated.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AppFailure catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _EmployeeHero extends StatelessWidget {
  const _EmployeeHero({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              _initials(employee.fullName),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            employee.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(employee.role.label),
          const SizedBox(height: AppSpacing.sm),
          EmployeeStatusBadge(isActive: employee.isActive),
        ],
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
