import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/presentation/providers/member_search_provider.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

import '../helpers/fake_members_repository.dart';

/// Waits until the provider's state satisfies [predicate] or the deadline
/// passes, polling every 10 ms.
Future<AsyncValue<List<Member>>> waitFor(
  ProviderContainer container,
  bool Function(AsyncValue<List<Member>>) predicate, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    final state = container.read(memberSearchProvider);
    if (predicate(state)) {
      return state;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  return container.read(memberSearchProvider);
}

ProviderContainer makeContainer(FakeMembersRepository repo) {
  final container = ProviderContainer(
    overrides: [membersRepositoryProvider.overrideWithValue(repo)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  final ahmed = FakeMembersRepository.makeTestMember(
    id: 'member-1',
    fullName: 'Ahmed Mohamed',
    phone: '01012345678',
  );
  final sara = FakeMembersRepository.makeTestMember(
    id: 'member-2',
    fullName: 'Sara Ali',
    phone: '01098765432',
    memberCode: 'GYM-000002',
  );

  // ---------------------------------------------------------------------------
  // Initial state
  // ---------------------------------------------------------------------------
  group('MemberSearchController – initial state', () {
    test('initial state is AsyncData with an empty list', () async {
      final container = makeContainer(FakeMembersRepository());
      // Poll until build() resolves from AsyncLoading → AsyncData.
      final state = await waitFor(
        container,
        (s) => s is AsyncData<List<Member>>,
      );
      expect(state, isA<AsyncData<List<Member>>>());
      expect(state.value, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // clear()
  // ---------------------------------------------------------------------------
  group('MemberSearchController.clear', () {
    test('clear() sets state to AsyncData([])', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed, sara]),
      );
      // Wait for initial build to complete.
      await waitFor(container, (s) => s is AsyncData<List<Member>>);

      container.read(memberSearchProvider.notifier).clear();

      final state = container.read(memberSearchProvider);
      expect(state, isA<AsyncData<List<Member>>>());
      expect(state.value, isEmpty);
    });

    test('clear() cancels any pending debounce timer', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed]),
      );
      // Wait for initial build to complete.
      await waitFor(container, (s) => s is AsyncData<List<Member>>);

      // Trigger a debounced search, then immediately clear before it fires.
      container.read(memberSearchProvider.notifier).onQueryChanged('Ahmed');
      container.read(memberSearchProvider.notifier).clear();

      // Wait longer than the debounce duration to confirm the search did not run.
      await Future<void>.delayed(
        MemberSearchController.debounceDuration + const Duration(milliseconds: 100),
      );

      final state = container.read(memberSearchProvider);
      expect(state.value, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  // onQueryChanged – debounced search
  // ---------------------------------------------------------------------------
  group('MemberSearchController.onQueryChanged', () {
    test('empty query sets state to AsyncData([])', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      container.read(memberSearchProvider.notifier).onQueryChanged('');

      await Future<void>.delayed(
        MemberSearchController.debounceDuration + const Duration(milliseconds: 100),
      );

      final state = container.read(memberSearchProvider);
      expect(state.value, isEmpty);
    });

    test('whitespace-only query sets state to AsyncData([])', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      container.read(memberSearchProvider.notifier).onQueryChanged('   ');

      await Future<void>.delayed(
        MemberSearchController.debounceDuration + const Duration(milliseconds: 100),
      );

      final state = container.read(memberSearchProvider);
      expect(state.value, isEmpty);
    });

    test('non-empty query eventually returns matching members', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed, sara]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      container.read(memberSearchProvider.notifier).onQueryChanged('Ahmed');

      final state = await waitFor(
        container,
        (s) => s is AsyncData<List<Member>> && s.value.isNotEmpty,
      );

      expect(state, isA<AsyncData<List<Member>>>());
      expect(state.value, contains(ahmed));
      expect(state.value, isNot(contains(sara)));
    });

    test('rapid typing only triggers one search (last query wins)', () async {
      var searchCallCount = 0;
      final trackingRepo = _TrackingFakeRepository(
        members: [ahmed, sara],
        onSearch: () => searchCallCount++,
      );
      final container = makeContainer(trackingRepo);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Simulate rapid typing – each call cancels the previous debounce.
      container.read(memberSearchProvider.notifier).onQueryChanged('A');
      container.read(memberSearchProvider.notifier).onQueryChanged('Ah');
      container.read(memberSearchProvider.notifier).onQueryChanged('Ahm');
      container.read(memberSearchProvider.notifier).onQueryChanged('Ahmed');

      await Future<void>.delayed(
        MemberSearchController.debounceDuration + const Duration(milliseconds: 100),
      );

      // Only one search should have been executed.
      expect(searchCallCount, 1);
    });

    test('query change after clear triggers a new search', () async {
      final container = makeContainer(
        FakeMembersRepository(members: [ahmed, sara]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));

      container.read(memberSearchProvider.notifier).clear();
      container.read(memberSearchProvider.notifier).onQueryChanged('Sara');

      final state = await waitFor(
        container,
        (s) => s is AsyncData<List<Member>> && s.value.isNotEmpty,
      );

      expect(state.value, contains(sara));
      expect(state.value, isNot(contains(ahmed)));
    });
  });
}

// ---------------------------------------------------------------------------
// Helper: fake repository that counts searchMembers calls
// ---------------------------------------------------------------------------
class _TrackingFakeRepository extends FakeMembersRepository {
  _TrackingFakeRepository({
    required super.members,
    required this.onSearch,
  });

  final void Function() onSearch;

  @override
  Future<List<Member>> searchMembers(String query, {int limit = 20}) async {
    onSearch();
    return super.searchMembers(query, limit: limit);
  }
}
