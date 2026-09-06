import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/usecases/get_member.dart';
import 'package:gym_management_app/features/members/presentation/providers/members_provider.dart';

/// Loads a single member for the details screen, keyed by member id.
///
/// Auto-disposes when the screen is removed from the tree. Invalidating
/// the provider (e.g. after a mutation) triggers a fresh fetch.
final memberDetailsProvider =
    FutureProvider.family.autoDispose<Member, String>((ref, id) async {
  final member = await GetMember(ref.read(membersRepositoryProvider))(id);
  if (member == null) {
    throw const UnexpectedFailure(message: 'This member could not be found.');
  }
  return member;
});
