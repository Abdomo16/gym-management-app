import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_form.dart';

/// Edit-member screen.
///
/// Pre-fills the form from the cached member details and submits only the
/// mutable fields. `member_code` and `organization_id` are never sent.
class EditMemberScreen extends ConsumerWidget {
  const EditMemberScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Member')),
      body: memberAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(
          failure: error is AppFailure ? error : null,
          message: error is AppFailure ? null : 'Could not load member.',
          onRetry: () => ref.invalidate(memberDetailsProvider(memberId)),
        ),
        data: (member) {
          final busy = ref.watch(membersControllerProvider) ==
              MemberActionStatus.busy;
          final role = ref.watch(currentProfileProvider)?.role;
          final showBranchPicker = role != UserRole.receptionist;

          return _EditForm(
            memberId: memberId,
            member: member,
            busy: busy,
            showBranchPicker: showBranchPicker,
          );
        },
      ),
    );
  }
}

class _EditForm extends ConsumerStatefulWidget {
  const _EditForm({
    required this.memberId,
    required this.member,
    required this.busy,
    required this.showBranchPicker,
  });

  final String memberId;
  final Member member;
  final bool busy;
  final bool showBranchPicker;

  @override
  ConsumerState<_EditForm> createState() => _EditFormState();
}

class _EditFormState extends ConsumerState<_EditForm> {
  String? _serverError;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: MemberForm(
        initial: widget.member,
        onSubmit: ({
          required fullName,
          required phone,
          branchId,
          gender,
          dateOfBirth,
          notes,
          subscriptionPlanId,
        }) => _save(
          fullName: fullName,
          phone: phone,
          branchId: branchId,
          gender: gender,
          dateOfBirth: dateOfBirth,
          notes: notes,
        ),
        submitLabel: 'Save Changes',
        busy: widget.busy,
        serverError: _serverError,
        showBranchPicker: widget.showBranchPicker,
      ),
    );
  }

  Future<void> _save({
    required String fullName,
    required String phone,
    String? branchId,
    String? gender,
    DateTime? dateOfBirth,
    String? notes,
  }) async {
    setState(() => _serverError = null);
    try {
      await ref.read(membersControllerProvider.notifier).updateMember(
        id: widget.memberId,
        branchId: branchId,
        fullName: fullName,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
        notes: notes,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Member updated successfully.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } on AppFailure catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(() => _serverError = 'Something went wrong. Please try again.');
    }
  }
}
