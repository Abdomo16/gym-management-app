import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';

/// Maps a `public.members` row (PostgREST map) into the [Member] entity.
abstract final class MemberMapper {
  static Member fromMap(Map<String, dynamic> map) {
    final status = MemberStatusX.fromWireName(map['status'] as String?);
    if (status == null) {
      throw const ValidationFailure(
        message: 'A member has an unsupported status. Please contact your '
            'gym administrator.',
      );
    }
    return Member(
      id: map['id'] as String,
      organizationId: map['organization_id'] as String,
      branchId: map['branch_id'] as String?,
      memberCode: map['member_code'] as String?,
      fullName: map['full_name'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      gender: MemberGenderX.fromWireName(map['gender'] as String?),
      dateOfBirth: _parseDate(map['date_of_birth']),
      photoUrl: map['photo_url'] as String?,
      notes: map['notes'] as String?,
      status: status,
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}
