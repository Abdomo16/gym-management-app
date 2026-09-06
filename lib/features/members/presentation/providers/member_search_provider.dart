import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/search_members.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// Debounced member search.
///
/// Typing in the search bar calls [onQueryChanged], which cancels any pending
/// timer and re-runs the search after [debounceDuration]. Empty queries clear
/// the results so the screen can fall back to the normal member list.
class MemberSearchController extends AsyncNotifier<List<Member>> {
  static const Duration debounceDuration = Duration(milliseconds: 350);
  static const int _resultLimit = 20;

  Timer? _debounce;
  String _activeQuery = '';

  @override
  Future<List<Member>> build() async {
    ref.onDispose(() => _debounce?.cancel());
    if (_activeQuery.isEmpty) {
      return const [];
    }
    return SearchMembers(ref.read(membersRepositoryProvider))(
      _activeQuery,
      limit: _resultLimit,
    );
  }

  /// Debounced entry point from the search bar.
  void onQueryChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(debounceDuration, () {
      _run(query);
    });
  }

  Future<void> _run(String query) async {
    _activeQuery = query.trim();
    if (_activeQuery.isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }

  void clear() {
    _debounce?.cancel();
    _activeQuery = '';
    state = const AsyncData([]);
  }
}

/// Search results; empty when no query is active.
final memberSearchProvider =
    AsyncNotifierProvider<MemberSearchController, List<Member>>(
      MemberSearchController.new,
    );
