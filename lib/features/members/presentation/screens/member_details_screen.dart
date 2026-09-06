import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:gym_management_app/app/router/app_routes.dart';
import 'package:gym_management_app/app/theme/app_spacing.dart';
import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/widgets/app_error_state.dart';
import 'package:gym_management_app/core/widgets/app_loading.dart';
import 'package:gym_management_app/features/auth/domain/entities/user_profile.dart';
import 'package:gym_management_app/features/auth/presentation/providers/auth_state_provider.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_details_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_controller.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_info_card.dart';
import 'package:gym_management_app/features/members/presentation/widgets/member_status_badge.dart';

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
    final role = ref.watch(currentProfileProvider)?.role;
    final canEdit = role != null; // all roles can view; owner/manager/receptionist can create
    final canChangeStatus = role == UserRole.owner || role == UserRole.manager;

    if (!canEdit) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Edit button — all authenticated roles
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          tooltip: 'Edit member',
          onPressed: () =>
              context.push(RoutePaths.memberEdit(member.id)),
        ),
        // Status menu — owner/manager only
        if (canChangeStatus)
          _StatusMenuButton(member: member),
      ],
    );
  }
}

class _StatusMenuButton extends ConsumerWidget {
  const _StatusMenuButton({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(membersControllerProvider.notifier);
    final busy = ref.watch(membersControllerProvider) == MemberActionStatus.busy;

    return PopupMenuButton<MemberStatus>(
      icon: const Icon(Icons.more_vert_rounded),
      tooltip: 'Change status',
      enabled: !busy,
      itemBuilder: (_) => MemberStatus.values
          .where((s) => s != member.status)
          .map(
            (s) => PopupMenuItem(
              value: s,
              child: Text('Mark as ${s.label}'),
            ),
          )
          .toList(),
      onSelected: (newStatus) async {
        try {
          await controller.updateMemberStatus(
            id: member.id,
            status: newStatus,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Member marked as ${newStatus.label}.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } on AppFailure catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        }
      },
    );
  }
}

class _MemberDetailsBody extends StatelessWidget {
  const _MemberDetailsBody({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
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
