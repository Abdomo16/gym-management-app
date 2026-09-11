import 'package:gym_management_app/core/errors/app_failure.dart';
import 'package:gym_management_app/core/errors/exception_mapper.dart';
import 'package:gym_management_app/core/utils/phone_normalizer.dart';
import 'package:gym_management_app/features/members/data/datasources/members_remote_datasource.dart';
import 'package:gym_management_app/features/members/data/mappers/member_mapper.dart';
import 'package:gym_management_app/features/members/domain/entities/branch_summary.dart';
import 'package:gym_management_app/features/members/domain/entities/member.dart';
import 'package:gym_management_app/features/members/domain/repositories/members_repository.dart';

/// Supabase-backed implementation of [MembersRepository].
///
/// Phones are normalized before being stored so equivalent representations
/// (spacing, dashes, leading zeros) collapse into one value; the database's
/// unique constraint remains the authority for duplicate detection.
class SupabaseMembersRepository implements MembersRepository {
  SupabaseMembersRepository(this._dataSource);

  final MembersRemoteDataSource _dataSource;

  @override
  Future<List<Member>> getMembers({int limit = 50, int offset = 0}) async {
    try {
      final rows = await _dataSource.getMembers(limit: limit, offset: offset);
      return rows.map(MemberMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<List<Member>> searchMembers(String query, {int limit = 20}) async {
    try {
      final rows = await _dataSource.searchMembers(query, limit: limit);
      return rows.map(MemberMapper.fromMap).toList();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Member?> getMemberById(String id) async {
    try {
      final row = await _dataSource.getMemberById(id);
      return row == null ? null : MemberMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Member> createMember({
    required String organizationId,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      final row = await _dataSource.createMember(
        organizationId: organizationId,
        branchId: branchId,
        fullName: fullName.trim(),
        phone: PhoneNormalizer.normalize(phone),
        gender: gender,
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl,
        notes: notes,
      );
      return MemberMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Member> updateMember({
    required String id,
    String? branchId,
    required String fullName,
    required String phone,
    String? gender,
    DateTime? dateOfBirth,
    String? photoUrl,
    String? notes,
  }) async {
    try {
      final row = await _dataSource.updateMember(
        id: id,
        branchId: branchId,
        fullName: fullName.trim(),
        phone: PhoneNormalizer.normalize(phone),
        gender: gender,
        dateOfBirth: dateOfBirth,
        photoUrl: photoUrl,
        notes: notes,
      );
      return MemberMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<Member> updateMemberStatus({
    required String id,
    required MemberStatus status,
  }) async {
    try {
      final row = await _dataSource.updateMemberStatus(
        id: id,
        status: status.name,
      );
      return MemberMapper.fromMap(row);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<void> deleteMember(String id) async {
    try {
      await _dataSource.deleteMember(id);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }

  @override
  Future<List<BranchSummary>> getOrganizationBranches(
    String organizationId,
  ) async {
    try {
      return await _dataSource.getOrganizationBranches(organizationId);
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw ExceptionMapper.map(error);
    }
  }
}
