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
import 'package:gym_management_app/features/attendance/presentation/providers/member_attendance_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/widgets/attendance_history_card.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_info_card.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_status_badge.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/member_subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_controller.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/current_subscription_card.dart';
import 'package:gym_management_app/features/subscriptions/presentation/widgets/subscription_history_card.dart';

/// Displays full detail for a single member.
class MemberDetailsScreen extends ConsumerWidget {
  const MemberDetailsScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Details'),
        actions: [
          memberAsync.whenOrNull(
            data: (member) => _DetailsActions(member: member),
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: memberAsync.when(
        loading: () => const AppLoading(),
        error: (error, _) => AppErrorState(
          failure: error is AppFailure ? error : null,
          message: error is AppFailure ? null : 'Could not load member details.',
          onRetry: () =>
              ref.invalidate(memberDetailsProvider(memberId)),
        ),
        data: (member) => _MemberDetailsBody(member: member),
      ),
    );
  }
}

class _DetailsActions extends ConsumerWidget {
  const _DetailsActions({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'Member actions',
      onPressed: () => showMemberActionsSheet(context, ref, member),
    );
  }
}

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

class _MemberDetailsBody extends ConsumerWidget {
  const _MemberDetailsBody({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero card with avatar + name + status
          _HeroCard(member: member),
          const SizedBox(height: AppSpacing.md),

          // Identity card
          MemberInfoCard(
            title: 'Identity',
            rows: {
              'Member ID': member.memberCode,
              'Phone': member.phone,
              'Gender': member.gender?.label,
              'Date of Birth': member.dateOfBirth != null
                  ? _formatDate(member.dateOfBirth!)
                  : null,
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Additional card
          MemberInfoCard(
            title: 'Additional',
            rows: {
              'Notes': member.notes,
              'Registered': member.createdAt != null
                  ? _formatDate(member.createdAt!)
                  : null,
            },
          ),
          const SizedBox(height: AppSpacing.sm),

          // Subscriptions (current + history)
          _SubscriptionSection(member: member),
          const SizedBox(height: AppSpacing.md),
          _AttendanceSection(memberId: member.id),
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final initials = _initials(member.fullName);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                initials,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              member.fullName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (member.memberCode != null) ...[
              const SizedBox(height: AppSpacing.xxs),
              Text(
                member.memberCode!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            MemberStatusBadge(status: member.status),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _AttendanceSection extends ConsumerWidget {
  const _AttendanceSection({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(memberAttendanceProvider(memberId));
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Attendance',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        attendanceAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppLoading(),
          ),
          error: (error, _) => AppErrorState(
            failure: error is AppFailure ? error : null,
            message: error is AppFailure
                ? null
                : 'Could not load attendance history.',
            onRetry: () =>
                ref.invalidate(memberAttendanceProvider(memberId)),
          ),
          data: (attendance) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AttendanceHistoryCard(attendance: attendance),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'Check In',
                icon: Icons.login_rounded,
                onPressed: () => context.push(
                  '${RoutePaths.checkIn}?memberId=${Uri.encodeComponent(memberId)}',
                ),
                expanded: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Current subscription + history for the member.
///
/// Frontend role checks only shape the UI (which actions appear); Supabase
/// RLS remains the actual security boundary for every operation.
class _SubscriptionSection extends ConsumerWidget {
  const _SubscriptionSection({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final role = ref.watch(currentProfileProvider)?.role;
    final canChangeStatus = role == UserRole.owner || role == UserRole.manager;

    final subscriptionsAsync = ref.watch(
      memberSubscriptionsProvider(member.id),
    );
    final planNamesById = {
      for (final plan
          in ref.watch(subscriptionPlansProvider).whenOrNull(
                data: (plans) => plans,
              ) ??
              const <SubscriptionPlan>[])
        plan.id: plan.name,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Subscription',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        subscriptionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
            child: AppLoading(),
          ),
          error: (error, _) => AppErrorState(
            failure: error is AppFailure ? error : null,
            message: error is AppFailure
                ? null
                : 'Could not load subscriptions.',
            onRetry: () =>
                ref.invalidate(memberSubscriptionsProvider(member.id)),
          ),
          data: (subscriptions) {
            if (subscriptions.isEmpty) {
              return _NoSubscriptionCard(
                memberId: member.id,
              );
            }
            final current = subscriptions.first;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CurrentSubscriptionCard(
                  subscription: current,
                  planName:
                      planNamesById[current.planId] ?? 'Subscription plan',
                  onRenew: () => context.push(
                    RoutePaths.memberSubscriptionCreate(member.id),
                  ),
                  onFreeze:
                      canChangeStatus &&
                          (current.status == SubscriptionStatus.active ||
                              current.status == SubscriptionStatus.expiring)
                      ? () => _confirmFreeze(context, ref, current)
                      : null,
                  onCancel:
                      canChangeStatus &&
                          current.status != SubscriptionStatus.cancelled
                      ? () => _confirmCancel(context, ref, current)
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                SubscriptionHistoryCard(
                  subscriptions: subscriptions,
                  planNamesById: planNamesById,
                  currentSubscriptionId: current.id,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Future<void> _confirmFreeze(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Freeze subscription?',
      message:
          'Freezing pauses access for this member until the plan period '
          'ends or the subscription is managed again. Continue?',
      confirmLabel: 'Freeze',
    );
    if (confirmed != true || !context.mounted) return;
    await _runStatusChange(
      context,
      ref,
      () => ref.read(subscriptionControllerProvider.notifier)
          .freezeSubscription(
            memberId: member.id,
            subscriptionId: subscription.id,
          ),
      successMessage: 'Subscription frozen.',
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref,
    Subscription subscription,
  ) async {
    final confirmed = await AppDialog.confirm(
      context: context,
      title: 'Cancel subscription?',
      message:
          'Cancelling ends this subscription immediately. The record stays '
          'in the member\'s history. Continue?',
      confirmLabel: 'Cancel',
      confirmVariant: AppButtonVariant.danger,
    );
    if (confirmed != true || !context.mounted) return;
    await _runStatusChange(
      context,
      ref,
      () => ref.read(subscriptionControllerProvider.notifier)
          .cancelSubscription(
            memberId: member.id,
            subscriptionId: subscription.id,
          ),
      successMessage: 'Subscription cancelled.',
    );
  }

  Future<void> _runStatusChange(
    BuildContext context,
    WidgetRef ref,
    Future<Subscription> Function() action, {
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
}

class _NoSubscriptionCard extends ConsumerWidget {
  const _NoSubscriptionCard({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 40,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No active subscription',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            'Add a subscription so this member can start accessing the gym.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Add Subscription',
            icon: Icons.add_circle_outline,
            onPressed: () => context.push(
              RoutePaths.memberSubscriptionCreate(memberId),
            ),
            expanded: true,
          ),
        ],
      ),
    );
  }
}
