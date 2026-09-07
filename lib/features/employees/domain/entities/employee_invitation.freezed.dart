// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'employee_invitation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmployeeInvitation {

 String get id; String get organizationId; String? get branchId; String get fullName; String get email; UserRole get role; String get token; EmployeeInvitationStatus get status; DateTime? get expiresAt; DateTime? get createdAt;
/// Create a copy of EmployeeInvitation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmployeeInvitationCopyWith<EmployeeInvitation> get copyWith => _$EmployeeInvitationCopyWithImpl<EmployeeInvitation>(this as EmployeeInvitation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmployeeInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,branchId,fullName,email,role,token,status,expiresAt,createdAt);

@override
String toString() {
  return 'EmployeeInvitation(id: $id, organizationId: $organizationId, branchId: $branchId, fullName: $fullName, email: $email, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $EmployeeInvitationCopyWith<$Res>  {
  factory $EmployeeInvitationCopyWith(EmployeeInvitation value, $Res Function(EmployeeInvitation) _then) = _$EmployeeInvitationCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String? branchId, String fullName, String email, UserRole role, String token, EmployeeInvitationStatus status, DateTime? expiresAt, DateTime? createdAt
});




}
/// @nodoc
class _$EmployeeInvitationCopyWithImpl<$Res>
    implements $EmployeeInvitationCopyWith<$Res> {
  _$EmployeeInvitationCopyWithImpl(this._self, this._then);

  final EmployeeInvitation _self;
  final $Res Function(EmployeeInvitation) _then;

/// Create a copy of EmployeeInvitation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? branchId = freezed,Object? fullName = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmployeeInvitationStatus,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EmployeeInvitation].
extension EmployeeInvitationPatterns on EmployeeInvitation {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EmployeeInvitation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EmployeeInvitation() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EmployeeInvitation value)  $default,){
final _that = this;
switch (_that) {
case _EmployeeInvitation():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EmployeeInvitation value)?  $default,){
final _that = this;
switch (_that) {
case _EmployeeInvitation() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String? branchId,  String fullName,  String email,  UserRole role,  String token,  EmployeeInvitationStatus status,  DateTime? expiresAt,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EmployeeInvitation() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.fullName,_that.email,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String? branchId,  String fullName,  String email,  UserRole role,  String token,  EmployeeInvitationStatus status,  DateTime? expiresAt,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _EmployeeInvitation():
return $default(_that.id,_that.organizationId,_that.branchId,_that.fullName,_that.email,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String? branchId,  String fullName,  String email,  UserRole role,  String token,  EmployeeInvitationStatus status,  DateTime? expiresAt,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _EmployeeInvitation() when $default != null:
return $default(_that.id,_that.organizationId,_that.branchId,_that.fullName,_that.email,_that.role,_that.token,_that.status,_that.expiresAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc


class _EmployeeInvitation implements EmployeeInvitation {
  const _EmployeeInvitation({required this.id, required this.organizationId, this.branchId, required this.fullName, required this.email, required this.role, required this.token, required this.status, this.expiresAt, this.createdAt});


@override final  String id;
@override final  String organizationId;
@override final  String? branchId;
@override final  String fullName;
@override final  String email;
@override final  UserRole role;
@override final  String token;
@override final  EmployeeInvitationStatus status;
@override final  DateTime? expiresAt;
@override final  DateTime? createdAt;

/// Create a copy of EmployeeInvitation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EmployeeInvitationCopyWith<_EmployeeInvitation> get copyWith => __$EmployeeInvitationCopyWithImpl<_EmployeeInvitation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EmployeeInvitation&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.email, email) || other.email == email)&&(identical(other.role, role) || other.role == role)&&(identical(other.token, token) || other.token == token)&&(identical(other.status, status) || other.status == status)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,branchId,fullName,email,role,token,status,expiresAt,createdAt);

@override
String toString() {
  return 'EmployeeInvitation(id: $id, organizationId: $organizationId, branchId: $branchId, fullName: $fullName, email: $email, role: $role, token: $token, status: $status, expiresAt: $expiresAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$EmployeeInvitationCopyWith<$Res> implements $EmployeeInvitationCopyWith<$Res> {
  factory _$EmployeeInvitationCopyWith(_EmployeeInvitation value, $Res Function(_EmployeeInvitation) _then) = __$EmployeeInvitationCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String? branchId, String fullName, String email, UserRole role, String token, EmployeeInvitationStatus status, DateTime? expiresAt, DateTime? createdAt
});




}
/// @nodoc
class __$EmployeeInvitationCopyWithImpl<$Res>
    implements _$EmployeeInvitationCopyWith<$Res> {
  __$EmployeeInvitationCopyWithImpl(this._self, this._then);

  final _EmployeeInvitation _self;
  final $Res Function(_EmployeeInvitation) _then;

/// Create a copy of EmployeeInvitation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? branchId = freezed,Object? fullName = null,Object? email = null,Object? role = null,Object? token = null,Object? status = null,Object? expiresAt = freezed,Object? createdAt = freezed,}) {
  return _then(_EmployeeInvitation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,role: null == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as UserRole,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EmployeeInvitationStatus,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
