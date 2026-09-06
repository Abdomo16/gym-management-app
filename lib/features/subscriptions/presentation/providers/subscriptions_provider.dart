import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/network/supabase_client.dart';
import 'package:gym_management_app/features/subscriptions/data/datasources/subscriptions_remote_datasource.dart';
import 'package:gym_management_app/features/subscriptions/data/repositories/subscriptions_repository_impl.dart';
import 'package:gym_management_app/features/subscriptions/domain/repositories/subscription_repository.dart';

/// Resolves the concrete [SubscriptionRepository]. Tests override this
/// provider with an in-memory fake so widget tests never touch Supabase.
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return SupabaseSubscriptionRepository(
    SubscriptionsRemoteDataSource(client),
  );
});
