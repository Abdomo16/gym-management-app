import 'package:flutter/material.dart';

import 'package:gym_management_app/core/widgets/app_empty_state.dart';

/// Pre-configured empty states for the member list.
abstract final class MemberEmptyState {
  /// Shown when the member list is empty (no members created yet).
  static Widget noMembers({VoidCallback? onAdd}) => AppEmptyState(
    title: 'No members yet',
    message: 'Add your first member to get started.',
    icon: Icons.group_outlined,
    action: onAdd == null
        ? null
        : TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Member'),
          ),
  );

  /// Shown when a search query returns no results.
  static Widget noSearchResults() => const AppEmptyState(
    title: 'No members found',
    message: 'Try another name, phone number, or member ID.',
    icon: Icons.search_off_rounded,
  );
}
