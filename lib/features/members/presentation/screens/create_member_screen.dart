import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_form.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_controller.dart';

/// Create-member screen.
///
/// The form only collects mutable fields. The database generates the
/// `member_code`; the returned member is navigated to immediately so the
/// user can see the generated code.
class CreateMemberScreen extends ConsumerStatefulWidget {
  const CreateMemberScreen({super.key});

  @override
  ConsumerState<CreateMemberScreen> createState() => _CreateMemberScreenState();
}

class _CreateMemberScreenState extends ConsumerState<CreateMemberScreen> {
  String? _serverError;

  @override
  Widget build(BuildContext context) {
    final busy =
        ref.watch(membersControllerProvider) == MemberActionStatus.busy;
    final role = ref.watch(currentProfileProvider)?.role;

    // Receptionists are auto-assigned to their branch; show picker for others.
    final showBranchPicker = role != UserRole.receptionist;

    return Scaffold(
      appBar: AppBar(title: const Text('New Member')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: MemberForm(
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
            subscriptionPlanId: subscriptionPlanId,
          ),
          submitLabel: 'Create Member',
          busy: busy,
          serverError: _serverError,
          showBranchPicker: showBranchPicker,
        ),
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
    String? subscriptionPlanId,
  }) async {
    setState(() => _serverError = null);

    final orgCtx = ref.read(organizationContextProvider);
    final organizationId = orgCtx?.organizationId;
    if (organizationId == null) {
      setState(
        () => _serverError =
            'No active organization. Please sign in again.',
      );
      return;
    }

    // Receptionists are auto-assigned to their own branch.
    final role = ref.read(currentProfileProvider)?.role;
    final effectiveBranchId = role == UserRole.receptionist
        ? ref.read(currentProfileProvider)?.branchId
        : branchId;

    try {
      final member =
          await ref.read(membersControllerProvider.notifier).createMember(
            organizationId: organizationId,
            branchId: effectiveBranchId,
            fullName: fullName,
            phone: phone,
            gender: gender,
            dateOfBirth: dateOfBirth,
            notes: notes,
          );

      // A duration was selected — create the membership for the new member.
      // The member itself is already saved, so a subscription failure is
      // reported as a warning instead of blocking navigation.
      String? subscriptionWarning;
      if (subscriptionPlanId != null) {
        try {
          await ref
              .read(subscriptionControllerProvider.notifier)
              .createSubscription(
                organizationId: organizationId,
                memberId: member.id,
                planId: subscriptionPlanId,
              );
        } on AppFailure catch (e) {
          subscriptionWarning =
              'Member created, but the subscription failed: ${e.message}';
        } catch (_) {
          subscriptionWarning =
              'Member created, but the subscription failed. '
              'You can add it from the member profile.';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              subscriptionWarning ??
                  'Member created successfully. '
                      'ID: ${member.memberCode ?? member.id}',
            ),
            behavior: SnackBarBehavior.floating,
            duration: subscriptionWarning == null
                ? const Duration(seconds: 3)
                : const Duration(seconds: 6),
            backgroundColor: subscriptionWarning == null
                ? null
                : Theme.of(context).colorScheme.error,
          ),
        );
        // Navigate to details so the generated member code is visible.
        context.pushReplacement(RoutePaths.memberDetail(member.id));
      }
    } on AppFailure catch (e) {
      setState(() => _serverError = e.message);
    } catch (_) {
      setState(
        () => _serverError = 'Something went wrong. Please try again.',
      );
    }
  }
}
