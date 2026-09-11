import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_button.dart';
import 'package:gym_management_app/core/widgets/app_dialog.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/member_subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_controller.dart';

/// Bottom-sheet menu with the member's actions: edit, add subscription,
/// freeze/cancel the current membership, and — for the owner only —
/// delete the member permanently.
///
/// Role checks shape the UI only; Supabase RLS remains the security
/// boundary for every operation.
Future<void> showMemberActionsSheet(
  BuildContext context,
  WidgetRef ref,
  Member member,
) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final role = ref.read(currentProfileProvider)?.role;
  final canChangeStatus = role == UserRole.owner || role == UserRole.manager;
  final canDelete = role == UserRole.owner;

  // Current subscription drives whether freeze/cancel apply. Cached by
  // the provider, so this does not trigger a network round-trip.
  final subscriptions =
      ref.read(memberSubscriptionsProvider(member.id)).whenOrNull(
            data: (list) => list,
          ) ??
          const <Subscription>[];
  final current = subscriptions.isEmpty ? null : subscriptions.first;
  final canFreeze = canChangeStatus &&
      current != null &&
      (current.status == SubscriptionStatus.active ||
          current.status == SubscriptionStatus.expiring);
  final canCancel = canChangeStatus &&
      current != null &&
      current.status != SubscriptionStatus.cancelled;

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit member'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(RoutePaths.memberEdit(member.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded),
            title: const Text('Add subscription'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              context.push(RoutePaths.memberSubscriptionCreate(member.id));
            },
          ),
          ListTile(
            leading: const Icon(Icons.ac_unit_outlined),
            title: const Text('Freeze membership'),
            enabled: canFreeze,
            onTap: canFreeze
                ? () {
                    Navigator.of(sheetContext).pop();
                    _confirmFreezeMembership(context, ref, member, current);
                  }
                : null,
          ),
          ListTile(
            leading: Icon(
              Icons.cancel_outlined,
              color: canCancel ? null : colorScheme.onSurface.withValues(alpha: 0.38),
            ),
            title: const Text('Cancel membership'),
            enabled: canCancel,
            onTap: canCancel
                ? () {
                    Navigator.of(sheetContext).pop();
                    _confirmCancelMembership(context, ref, member, current);
                  }
                : null,
          ),
          if (canDelete) ...[
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded,
                  color: colorScheme.error),
              title: Text(
                'Delete member',
                style: TextStyle(color: colorScheme.error),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _confirmDeleteMember(context, ref, member);
              },
            ),
          ],
        ],
      ),
    ),
  );
}

Future<void> _confirmFreezeMembership(
  BuildContext context,
  WidgetRef ref,
  Member member,
  Subscription subscription,
) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: 'Freeze membership?',
    message:
        'Freezing pauses access for this member until the plan period ends '
        'or the subscription is managed again. Continue?',
    confirmLabel: 'Freeze',
  );
  if (confirmed != true || !context.mounted) return;
  await _runSubscriptionChange(
    context,
    ref,
    action: () =>
        ref.read(subscriptionControllerProvider.notifier).freezeSubscription(
              memberId: member.id,
              subscriptionId: subscription.id,
            ),
    successMessage: 'Membership frozen.',
  );
}

Future<void> _confirmCancelMembership(
  BuildContext context,
  WidgetRef ref,
  Member member,
  Subscription subscription,
) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: 'Cancel membership?',
    message:
        'Cancelling ends this subscription immediately. The record stays in '
        'the member\'s history. Continue?',
    confirmLabel: 'Cancel',
    confirmVariant: AppButtonVariant.danger,
  );
  if (confirmed != true || !context.mounted) return;
  await _runSubscriptionChange(
    context,
    ref,
    action: () =>
        ref.read(subscriptionControllerProvider.notifier).cancelSubscription(
              memberId: member.id,
              subscriptionId: subscription.id,
            ),
    successMessage: 'Membership cancelled.',
  );
}

Future<void> _runSubscriptionChange(
  BuildContext context,
  WidgetRef ref, {
  required Future<Subscription> Function() action,
  required String successMessage,
}) async {
  try {
    await action();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } on AppFailure catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

Future<void> _confirmDeleteMember(
  BuildContext context,
  WidgetRef ref,
  Member member,
) async {
  final confirmed = await AppDialog.confirm(
    context: context,
    title: 'Delete member?',
    message:
        '${member.fullName} and all related records — subscriptions, '
        'attendance and payments — will be permanently deleted. '
        'This cannot be undone.',
    confirmLabel: 'Delete',
    confirmVariant: AppButtonVariant.danger,
  );
  if (confirmed != true || !context.mounted) return;

  try {
    await ref.read(membersControllerProvider.notifier).deleteMember(
          id: member.id,
        );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${member.fullName} was deleted.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    // The member no longer exists — leave the details screen.
    context.go(RoutePaths.members);
  } on AppFailure catch (error) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Something went wrong. Please try again.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
