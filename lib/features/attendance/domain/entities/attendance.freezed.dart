// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Attendance {

 String get id; String get organizationId; String get memberId; String? get branchId; String get checkedInBy; DateTime get checkInDay; DateTime get checkInAt;
/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AttendanceCopyWith<Attendance> get copyWith => _$AttendanceCopyWithImpl<Attendance>(this as Attendance, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.checkedInBy, checkedInBy) || other.checkedInBy == checkedInBy)&&(identical(other.checkInDay, checkInDay) || other.checkInDay == checkInDay)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,memberId,branchId,checkedInBy,checkInDay,checkInAt);

@override
String toString() {
  return 'Attendance(id: $id, organizationId: $organizationId, memberId: $memberId, branchId: $branchId, checkedInBy: $checkedInBy, checkInDay: $checkInDay, checkInAt: $checkInAt)';
}


}

/// @nodoc
abstract mixin class $AttendanceCopyWith<$Res>  {
  factory $AttendanceCopyWith(Attendance value, $Res Function(Attendance) _then) = _$AttendanceCopyWithImpl;
@useResult
$Res call({
 String id, String organizationId, String memberId, String? branchId, String checkedInBy, DateTime checkInDay, DateTime checkInAt
});




}
/// @nodoc
class _$AttendanceCopyWithImpl<$Res>
    implements $AttendanceCopyWith<$Res> {
  _$AttendanceCopyWithImpl(this._self, this._then);

  final Attendance _self;
  final $Res Function(Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? branchId = freezed,Object? checkedInBy = null,Object? checkInDay = null,Object? checkInAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,checkedInBy: null == checkedInBy ? _self.checkedInBy : checkedInBy // ignore: cast_nullable_to_non_nullable
as String,checkInDay: null == checkInDay ? _self.checkInDay : checkInDay // ignore: cast_nullable_to_non_nullable
as DateTime,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Attendance].
extension AttendancePatterns on Attendance {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Attendance value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Attendance value)  $default,){
final _that = this;
switch (_that) {
case _Attendance():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Attendance value)?  $default,){
final _that = this;
switch (_that) {
case _Attendance() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String organizationId,  String memberId,  String? branchId,  String checkedInBy,  DateTime checkInDay,  DateTime checkInAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.branchId,_that.checkedInBy,_that.checkInDay,_that.checkInAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String organizationId,  String memberId,  String? branchId,  String checkedInBy,  DateTime checkInDay,  DateTime checkInAt)  $default,) {final _that = this;
switch (_that) {
case _Attendance():
return $default(_that.id,_that.organizationId,_that.memberId,_that.branchId,_that.checkedInBy,_that.checkInDay,_that.checkInAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String organizationId,  String memberId,  String? branchId,  String checkedInBy,  DateTime checkInDay,  DateTime checkInAt)?  $default,) {final _that = this;
switch (_that) {
case _Attendance() when $default != null:
return $default(_that.id,_that.organizationId,_that.memberId,_that.branchId,_that.checkedInBy,_that.checkInDay,_that.checkInAt);case _:
  return null;

}
}

}

/// @nodoc


class _Attendance implements Attendance {
  const _Attendance({required this.id, required this.organizationId, required this.memberId, this.branchId, required this.checkedInBy, required this.checkInDay, required this.checkInAt});
  

@override final  String id;
@override final  String organizationId;
@override final  String memberId;
@override final  String? branchId;
@override final  String checkedInBy;
@override final  DateTime checkInDay;
@override final  DateTime checkInAt;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AttendanceCopyWith<_Attendance> get copyWith => __$AttendanceCopyWithImpl<_Attendance>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Attendance&&(identical(other.id, id) || other.id == id)&&(identical(other.organizationId, organizationId) || other.organizationId == organizationId)&&(identical(other.memberId, memberId) || other.memberId == memberId)&&(identical(other.branchId, branchId) || other.branchId == branchId)&&(identical(other.checkedInBy, checkedInBy) || other.checkedInBy == checkedInBy)&&(identical(other.checkInDay, checkInDay) || other.checkInDay == checkInDay)&&(identical(other.checkInAt, checkInAt) || other.checkInAt == checkInAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,organizationId,memberId,branchId,checkedInBy,checkInDay,checkInAt);

@override
String toString() {
  return 'Attendance(id: $id, organizationId: $organizationId, memberId: $memberId, branchId: $branchId, checkedInBy: $checkedInBy, checkInDay: $checkInDay, checkInAt: $checkInAt)';
}


}

/// @nodoc
abstract mixin class _$AttendanceCopyWith<$Res> implements $AttendanceCopyWith<$Res> {
  factory _$AttendanceCopyWith(_Attendance value, $Res Function(_Attendance) _then) = __$AttendanceCopyWithImpl;
@override @useResult
$Res call({
 String id, String organizationId, String memberId, String? branchId, String checkedInBy, DateTime checkInDay, DateTime checkInAt
});




}
/// @nodoc
class __$AttendanceCopyWithImpl<$Res>
    implements _$AttendanceCopyWith<$Res> {
  __$AttendanceCopyWithImpl(this._self, this._then);

  final _Attendance _self;
  final $Res Function(_Attendance) _then;

/// Create a copy of Attendance
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? organizationId = null,Object? memberId = null,Object? branchId = freezed,Object? checkedInBy = null,Object? checkInDay = null,Object? checkInAt = null,}) {
  return _then(_Attendance(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,organizationId: null == organizationId ? _self.organizationId : organizationId // ignore: cast_nullable_to_non_nullable
as String,memberId: null == memberId ? _self.memberId : memberId // ignore: cast_nullable_to_non_nullable
as String,branchId: freezed == branchId ? _self.branchId : branchId // ignore: cast_nullable_to_non_nullable
as String?,checkedInBy: null == checkedInBy ? _self.checkedInBy : checkedInBy // ignore: cast_nullable_to_non_nullable
as String,checkInDay: null == checkInDay ? _self.checkInDay : checkInDay // ignore: cast_nullable_to_non_nullable
as DateTime,checkInAt: null == checkInAt ? _self.checkInAt : checkInAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
