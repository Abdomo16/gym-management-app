import 'package:gym_management_app/features/auth/domain/entities/auth_state.dart';
import 'package:gym_management_app/features/auth/domain/repositories/auth_repository.dart';

/// Creates the first organization and owner profile through the approved
/// `create_organization_with_owner` RPC, then restores the session state.
class CreateOrganization {
  const CreateOrganization(this._repository);

  final AuthRepository _repository;

  Future<AuthState> call({
    required String orgName,
    required String ownerFullName,
    String? ownerPhone,
    required String timezone,
  }) {
    return _repository.createOrganizationWithOwner(
      orgName: orgName,
      ownerFullName: ownerFullName,
      ownerPhone: ownerPhone,
      timezone: timezone,
    );
  }
}
