// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_recent_check_in.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardRecentCheckIn {

 Attendance get attendance; String get memberName; String? get memberCode;
/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardRecentCheckInCopyWith<DashboardRecentCheckIn> get copyWith => _$DashboardRecentCheckInCopyWithImpl<DashboardRecentCheckIn>(this as DashboardRecentCheckIn, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardRecentCheckIn&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode));
}


@override
int get hashCode => Object.hash(runtimeType,attendance,memberName,memberCode);

@override
String toString() {
  return 'DashboardRecentCheckIn(attendance: $attendance, memberName: $memberName, memberCode: $memberCode)';
}


}

/// @nodoc
abstract mixin class $DashboardRecentCheckInCopyWith<$Res>  {
  factory $DashboardRecentCheckInCopyWith(DashboardRecentCheckIn value, $Res Function(DashboardRecentCheckIn) _then) = _$DashboardRecentCheckInCopyWithImpl;
@useResult
$Res call({
 Attendance attendance, String memberName, String? memberCode
});


$AttendanceCopyWith<$Res> get attendance;

}
/// @nodoc
class _$DashboardRecentCheckInCopyWithImpl<$Res>
    implements $DashboardRecentCheckInCopyWith<$Res> {
  _$DashboardRecentCheckInCopyWithImpl(this._self, this._then);

  final DashboardRecentCheckIn _self;
  final $Res Function(DashboardRecentCheckIn) _then;

/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? attendance = null,Object? memberName = null,Object? memberCode = freezed,}) {
  return _then(_self.copyWith(
attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceCopyWith<$Res> get attendance {
  
  return $AttendanceCopyWith<$Res>(_self.attendance, (value) {
    return _then(_self.copyWith(attendance: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardRecentCheckIn].
extension DashboardRecentCheckInPatterns on DashboardRecentCheckIn {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardRecentCheckIn value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardRecentCheckIn() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardRecentCheckIn value)  $default,){
final _that = this;
switch (_that) {
case _DashboardRecentCheckIn():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardRecentCheckIn value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardRecentCheckIn() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Attendance attendance,  String memberName,  String? memberCode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardRecentCheckIn() when $default != null:
return $default(_that.attendance,_that.memberName,_that.memberCode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Attendance attendance,  String memberName,  String? memberCode)  $default,) {final _that = this;
switch (_that) {
case _DashboardRecentCheckIn():
return $default(_that.attendance,_that.memberName,_that.memberCode);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Attendance attendance,  String memberName,  String? memberCode)?  $default,) {final _that = this;
switch (_that) {
case _DashboardRecentCheckIn() when $default != null:
return $default(_that.attendance,_that.memberName,_that.memberCode);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardRecentCheckIn implements DashboardRecentCheckIn {
  const _DashboardRecentCheckIn({required this.attendance, required this.memberName, this.memberCode});
  

@override final  Attendance attendance;
@override final  String memberName;
@override final  String? memberCode;

/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardRecentCheckInCopyWith<_DashboardRecentCheckIn> get copyWith => __$DashboardRecentCheckInCopyWithImpl<_DashboardRecentCheckIn>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardRecentCheckIn&&(identical(other.attendance, attendance) || other.attendance == attendance)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode));
}


@override
int get hashCode => Object.hash(runtimeType,attendance,memberName,memberCode);

@override
String toString() {
  return 'DashboardRecentCheckIn(attendance: $attendance, memberName: $memberName, memberCode: $memberCode)';
}


}

/// @nodoc
abstract mixin class _$DashboardRecentCheckInCopyWith<$Res> implements $DashboardRecentCheckInCopyWith<$Res> {
  factory _$DashboardRecentCheckInCopyWith(_DashboardRecentCheckIn value, $Res Function(_DashboardRecentCheckIn) _then) = __$DashboardRecentCheckInCopyWithImpl;
@override @useResult
$Res call({
 Attendance attendance, String memberName, String? memberCode
});


@override $AttendanceCopyWith<$Res> get attendance;

}
/// @nodoc
class __$DashboardRecentCheckInCopyWithImpl<$Res>
    implements _$DashboardRecentCheckInCopyWith<$Res> {
  __$DashboardRecentCheckInCopyWithImpl(this._self, this._then);

  final _DashboardRecentCheckIn _self;
  final $Res Function(_DashboardRecentCheckIn) _then;

/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? attendance = null,Object? memberName = null,Object? memberCode = freezed,}) {
  return _then(_DashboardRecentCheckIn(
attendance: null == attendance ? _self.attendance : attendance // ignore: cast_nullable_to_non_nullable
as Attendance,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of DashboardRecentCheckIn
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AttendanceCopyWith<$Res> get attendance {
  
  return $AttendanceCopyWith<$Res>(_self.attendance, (value) {
    return _then(_self.copyWith(attendance: value));
  });
}
}

// dart format on
