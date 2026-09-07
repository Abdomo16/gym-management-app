import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/utils/validators.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_text_field.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/employees/domain/entities/employee.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/presentation/providers/organization_branches_provider.dart';

class EmployeeForm extends ConsumerStatefulWidget {
  const EmployeeForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.submitLabel,
    this.busy = false,
    this.serverError,
  });

  final Employee? initial;
  final void Function({
    required String fullName,
    required String? phone,
    required UserRole role,
    required String? branchId,
  })
  onSubmit;
  final String submitLabel;
  final bool busy;
  final String? serverError;

  @override
  ConsumerState<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late UserRole _role;
  String? _branchId;

  bool get isInvite => widget.initial == null;

  @override
  void initState() {
    super.initState();
    final employee = widget.initial;
    _nameController = TextEditingController(text: employee?.fullName ?? '');
    _phoneController = TextEditingController(text: employee?.phone ?? '');
    _role = employee?.role ?? UserRole.receptionist;
    _branchId = employee?.branchId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      role: _role,
      branchId: _branchId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final branchesAsync = ref.watch(organizationBranchesProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Full name *',
            controller: _nameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: (value) =>
                Validators.required(value, message: 'Full name is required.'),
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: isInvite ? 'Phone' : 'Phone',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              return Validators.phone(value);
            },
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<UserRole>(
            initialValue: _role,
            decoration: const InputDecoration(labelText: 'Role *'),
            items: const [
              DropdownMenuItem(value: UserRole.manager, child: Text('Manager')),
              DropdownMenuItem(
                value: UserRole.receptionist,
                child: Text('Receptionist'),
              ),
            ],
            onChanged: widget.busy
                ? null
                : (role) {
                    if (role != null) setState(() => _role = role);
                  },
          ),
          const SizedBox(height: AppSpacing.md),
          branchesAsync.when(
            loading: () =>
                const _BranchField(branches: [], value: null, enabled: false),
            error: (error, stackTrace) =>
                const _BranchField(branches: [], value: null, enabled: false),
            data: (branches) => _BranchField(
              branches: branches,
              value: _branchId,
              enabled: !widget.busy,
              onChanged: (branchId) => setState(() => _branchId = branchId),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (widget.serverError != null) ...[
            Text(
              widget.serverError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          AppButton(
            label: widget.submitLabel,
            icon: isInvite ? Icons.key_outlined : Icons.save_outlined,
            busy: widget.busy,
            expanded: true,
            onPressed: widget.busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class _BranchField extends StatelessWidget {
  const _BranchField({
    required this.branches,
    required this.value,
    required this.enabled,
    this.onChanged,
  });

  final List<BranchSummary> branches;
  final String? value;
  final bool enabled;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final validValue = branches.any((branch) => branch.id == value)
        ? value
        : null;
    return DropdownButtonFormField<String>(
      initialValue: validValue,
      decoration: const InputDecoration(labelText: 'Branch *'),
      items: [
        for (final branch in branches)
          DropdownMenuItem(value: branch.id, child: Text(branch.name)),
      ],
      validator: (selected) => selected == null ? 'Select a branch.' : null,
      onChanged: enabled && branches.isNotEmpty ? onChanged : null,
    );
  }
}
