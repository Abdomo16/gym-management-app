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
import 'package:gym_management_app/features/attendance/presentation/providers/check_in_controller.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/check_in_eligibility_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/providers/member_attendance_provider.dart';
import 'package:gym_management_app/features/attendance/presentation/widgets/attendance_history_card.dart';
import 'package:gym_management_app/features/attendance/presentation/widgets/check_in_eligibility_card.dart';
import 'package:gym_management_app/features/attendance/presentation/widgets/check_in_member_summary.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_search_provider.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_list_item.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_search_bar.dart';
import 'package:gym_management_app/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/member_subscriptions_provider.dart';
import 'package:gym_management_app/features/subscriptions/presentation/providers/subscription_plans_provider.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key, this.initialMemberId});

  final String? initialMemberId;

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  String? _selectedMemberId;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _selectedMemberId = widget.initialMemberId;
  }

  void _selectMember(Member member) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _selectedMemberId = member.id);
  }

  void _clearSelection() {
    setState(() => _selectedMemberId = null);
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = _selectedMemberId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check In Member'),
        leading: selectedId == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back to member search',
                onPressed: _clearSelection,
              ),
      ),
      body: selectedId == null
          ? _SearchView(
              query: _query,
              onQueryChanged: (query) {
                setState(() => _query = query);
                ref.read(memberSearchProvider.notifier).onQueryChanged(query);
              },
              onClear: () {
                setState(() => _query = '');
                ref.read(memberSearchProvider.notifier).clear();
              },
              onMemberSelected: _selectMember,
            )
          : _SelectedMemberView(memberId: selectedId),
    );
  }
}

class _SearchView extends ConsumerWidget {
  const _SearchView({
    required this.query,
    required this.onQueryChanged,
    required this.onClear,
    required this.onMemberSelected,
  });

  final String query;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClear;
  final ValueChanged<Member> onMemberSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(memberSearchProvider);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemberSearchBar(
            onChanged: onQueryChanged,
            onClear: onClear,
            hintText: 'Search name, phone or member code...',
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: query.trim().isEmpty
                ? const AppEmptyState(
                    icon: Icons.person_search_outlined,
                    title: 'Find a member to check in',
                    message:
                        'Search by name, phone or member code to begin.',
                  )
                : searchState.when(
                    loading: () => const AppLoading(),
                    error: (error, _) => AppErrorState(
                      failure: error is AppFailure ? error : null,
                      message: error is AppFailure
                          ? null
                          : 'Could not search members.',
                      onRetry: () => ref
                          .read(memberSearchProvider.notifier)
                          .onQueryChanged(query),
                    ),
                    data: (members) {
                      if (members.isEmpty) {
                        return const AppEmptyState(
                          icon: Icons.search_off_outlined,
                          title: 'No members found',
                          message:
                              'Try another name, phone number, or member code.',
                        );
                      }
                      return ListView.separated(
                        itemCount: members.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return MemberListItem(
                            member: member,
                            onTap: () => onMemberSelected(member),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectedMemberView extends ConsumerWidget {
  const _SelectedMemberView({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberAsync = ref.watch(memberDetailsProvider(memberId));
    return memberAsync.when(
      loading: () => const AppLoading(),
      error: (error, _) => AppErrorState(
        failure: error is AppFailure ? error : null,
        message: error is AppFailure ? null : 'Could not load this member.',
        onRetry: () => ref.invalidate(memberDetailsProvider(memberId)),
      ),
      data: (member) => _MemberCheckInContent(member: member),
    );
  }
}

class _MemberCheckInContent extends ConsumerWidget {
  const _MemberCheckInContent({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subscriptions = ref
        .watch(memberSubscriptionsProvider(member.id))
        .whenOrNull(data: (value) => value);
    final planNames = {
      for (final plan
          in ref.watch(subscriptionPlansProvider).whenOrNull(
                data: (value) => value,
              ) ??
              const <SubscriptionPlan>[])
        plan.id: plan.name,
    };
    final eligibilityAsync = ref.watch(
      checkInEligibilityProvider(member.id),
    );
    final attendanceAsync = ref.watch(memberAttendanceProvider(member.id));
    final busy = ref.watch(checkInControllerProvider) ==
        CheckInActionStatus.busy;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CheckInMemberSummary(
                member: member,
                subscription: subscriptions?.firstOrNull,
                planName: subscriptions == null || subscriptions.isEmpty
                    ? 'No subscription'
                    : planNames[subscriptions.first.planId] ??
                        'Subscription plan',
              ),
              const SizedBox(height: AppSpacing.md),
              eligibilityAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: AppLoading(),
                ),
                error: (error, _) => AppErrorState(
                  failure: error is AppFailure ? error : null,
                  message: error is AppFailure
                      ? null
                      : 'Could not check this member\'s eligibility.',
                  onRetry: () =>
                      ref.invalidate(checkInEligibilityProvider(member.id)),
                ),
                data: (eligibility) => CheckInEligibilityCard(
                  eligibility: eligibility,
                  busy: busy,
                  onCheckIn: () => _checkIn(context, ref, member),
                  onManageSubscription: () => context
                      .push(RoutePaths.memberSubscriptionCreate(member.id))
                      .then((_) {
                    ref.invalidate(memberSubscriptionsProvider(member.id));
                    ref.invalidate(checkInEligibilityProvider(member.id));
                  }),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              attendanceAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: AppLoading(),
                ),
                error: (error, _) => AppErrorState(
                  failure: error is AppFailure ? error : null,
                  message: error is AppFailure
                      ? null
                      : 'Could not load attendance history.',
                  onRetry: () =>
                      ref.invalidate(memberAttendanceProvider(member.id)),
                ),
                data: (attendance) => AttendanceHistoryCard(
                  attendance: attendance,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'View Member Details',
                variant: AppButtonVariant.outline,
                icon: Icons.person_outline,
                onPressed: () =>
                    context.push(RoutePaths.memberDetail(member.id)),
                expanded: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkIn(
    BuildContext context,
    WidgetRef ref,
    Member member,
  ) async {
    try {
      final attendance = await ref
          .read(checkInControllerProvider.notifier)
          .checkIn(member);
      if (!context.mounted) return;
      final time = attendance.checkInAt;
      final suffix = ' at ${time.hour.toString().padLeft(2, '0')}:'
          '${time.minute.toString().padLeft(2, '0')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Check-In Successful — ${member.fullName} checked in today$suffix.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AppFailure catch (error) {
      ref.invalidate(memberAttendanceProvider(member.id));
      ref.invalidate(checkInEligibilityProvider(member.id));
      if (!context.mounted) return;
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