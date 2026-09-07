import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_empty_state.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/employees/presentation/providers/employees_list_provider.dart';
import 'package:gym_management_app/features/employees/presentation/widgets/employee_list_item.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesAsync = ref.watch(employeesListProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppButton(
              label: 'Invite',
              icon: Icons.person_add_alt_1_outlined,
              size: AppButtonSize.small,
              onPressed: () => context.push(RoutePaths.employeeInvite),
            ),
          ),
        ],
      ),
      body: employeesAsync.when(
        loading: () => const AppLoading(label: 'Loading employees…'),
        error: (error, stackTrace) => AppErrorState(
          failure: error is AppFailure ? error : null,
          message: error is AppFailure
              ? null
              : 'Could not load employees. Please try again.',
          onRetry: () => ref.invalidate(employeesListProvider),
        ),
        data: (employees) => _EmployeeList(
          employees: employees,
          onRefresh: () => ref.read(employeesListProvider.notifier).refresh(),
          onInvite: () => context.push(RoutePaths.employeeInvite),
        ),
      ),
    );
  }
}

class _EmployeeList extends StatelessWidget {
  const _EmployeeList({
    required this.employees,
    required this.onRefresh,
    required this.onInvite,
  });

  final List<Employee> employees;
  final Future<void> Function() onRefresh;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    if (employees.isEmpty) {
      return AppEmptyState(
        icon: Icons.badge_outlined,
        title: 'No employees yet',
        message: 'Invite a manager or receptionist to your organization.',
        action: AppButton(
          label: 'Invite employee',
          icon: Icons.person_add_alt_1_outlined,
          onPressed: onInvite,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        itemCount: employees.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          indent: AppSpacing.md,
          endIndent: AppSpacing.md,
        ),
        itemBuilder: (context, index) {
          final employee = employees[index];
          return EmployeeListItem(
            employee: employee,
            onTap: () => context.push(RoutePaths.employeeDetail(employee.id)),
          );
        },
      ),
    );
  }
}
