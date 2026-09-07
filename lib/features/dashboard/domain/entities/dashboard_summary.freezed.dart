// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSummary {

 int get totalMembers; int get activeMembers; int get activeSubscriptions; int get expiringSoonSubscriptions; int get expiredSubscriptions; int get todayCheckIns;
/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<DashboardSummary> get copyWith => _$DashboardSummaryCopyWithImpl<DashboardSummary>(this as DashboardSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSummary&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.expiringSoonSubscriptions, expiringSoonSubscriptions) || other.expiringSoonSubscriptions == expiringSoonSubscriptions)&&(identical(other.expiredSubscriptions, expiredSubscriptions) || other.expiredSubscriptions == expiredSubscriptions)&&(identical(other.todayCheckIns, todayCheckIns) || other.todayCheckIns == todayCheckIns));
}


@override
int get hashCode => Object.hash(runtimeType,totalMembers,activeMembers,activeSubscriptions,expiringSoonSubscriptions,expiredSubscriptions,todayCheckIns);

@override
String toString() {
  return 'DashboardSummary(totalMembers: $totalMembers, activeMembers: $activeMembers, activeSubscriptions: $activeSubscriptions, expiringSoonSubscriptions: $expiringSoonSubscriptions, expiredSubscriptions: $expiredSubscriptions, todayCheckIns: $todayCheckIns)';
}


}

/// @nodoc
abstract mixin class $DashboardSummaryCopyWith<$Res>  {
  factory $DashboardSummaryCopyWith(DashboardSummary value, $Res Function(DashboardSummary) _then) = _$DashboardSummaryCopyWithImpl;
@useResult
$Res call({
 int totalMembers, int activeMembers, int activeSubscriptions, int expiringSoonSubscriptions, int expiredSubscriptions, int todayCheckIns
});




}
/// @nodoc
class _$DashboardSummaryCopyWithImpl<$Res>
    implements $DashboardSummaryCopyWith<$Res> {
  _$DashboardSummaryCopyWithImpl(this._self, this._then);

  final DashboardSummary _self;
  final $Res Function(DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalMembers = null,Object? activeMembers = null,Object? activeSubscriptions = null,Object? expiringSoonSubscriptions = null,Object? expiredSubscriptions = null,Object? todayCheckIns = null,}) {
  return _then(_self.copyWith(
totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,expiringSoonSubscriptions: null == expiringSoonSubscriptions ? _self.expiringSoonSubscriptions : expiringSoonSubscriptions // ignore: cast_nullable_to_non_nullable
as int,expiredSubscriptions: null == expiredSubscriptions ? _self.expiredSubscriptions : expiredSubscriptions // ignore: cast_nullable_to_non_nullable
as int,todayCheckIns: null == todayCheckIns ? _self.todayCheckIns : todayCheckIns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardSummary].
extension DashboardSummaryPatterns on DashboardSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSummary value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalMembers,  int activeMembers,  int activeSubscriptions,  int expiringSoonSubscriptions,  int expiredSubscriptions,  int todayCheckIns)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totalMembers,_that.activeMembers,_that.activeSubscriptions,_that.expiringSoonSubscriptions,_that.expiredSubscriptions,_that.todayCheckIns);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalMembers,  int activeMembers,  int activeSubscriptions,  int expiringSoonSubscriptions,  int expiredSubscriptions,  int todayCheckIns)  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary():
return $default(_that.totalMembers,_that.activeMembers,_that.activeSubscriptions,_that.expiringSoonSubscriptions,_that.expiredSubscriptions,_that.todayCheckIns);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalMembers,  int activeMembers,  int activeSubscriptions,  int expiringSoonSubscriptions,  int expiredSubscriptions,  int todayCheckIns)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSummary() when $default != null:
return $default(_that.totalMembers,_that.activeMembers,_that.activeSubscriptions,_that.expiringSoonSubscriptions,_that.expiredSubscriptions,_that.todayCheckIns);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSummary implements DashboardSummary {
  const _DashboardSummary({required this.totalMembers, required this.activeMembers, required this.activeSubscriptions, required this.expiringSoonSubscriptions, required this.expiredSubscriptions, required this.todayCheckIns});
  

@override final  int totalMembers;
@override final  int activeMembers;
@override final  int activeSubscriptions;
@override final  int expiringSoonSubscriptions;
@override final  int expiredSubscriptions;
@override final  int todayCheckIns;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSummaryCopyWith<_DashboardSummary> get copyWith => __$DashboardSummaryCopyWithImpl<_DashboardSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSummary&&(identical(other.totalMembers, totalMembers) || other.totalMembers == totalMembers)&&(identical(other.activeMembers, activeMembers) || other.activeMembers == activeMembers)&&(identical(other.activeSubscriptions, activeSubscriptions) || other.activeSubscriptions == activeSubscriptions)&&(identical(other.expiringSoonSubscriptions, expiringSoonSubscriptions) || other.expiringSoonSubscriptions == expiringSoonSubscriptions)&&(identical(other.expiredSubscriptions, expiredSubscriptions) || other.expiredSubscriptions == expiredSubscriptions)&&(identical(other.todayCheckIns, todayCheckIns) || other.todayCheckIns == todayCheckIns));
}


@override
int get hashCode => Object.hash(runtimeType,totalMembers,activeMembers,activeSubscriptions,expiringSoonSubscriptions,expiredSubscriptions,todayCheckIns);

@override
String toString() {
  return 'DashboardSummary(totalMembers: $totalMembers, activeMembers: $activeMembers, activeSubscriptions: $activeSubscriptions, expiringSoonSubscriptions: $expiringSoonSubscriptions, expiredSubscriptions: $expiredSubscriptions, todayCheckIns: $todayCheckIns)';
}


}

/// @nodoc
abstract mixin class _$DashboardSummaryCopyWith<$Res> implements $DashboardSummaryCopyWith<$Res> {
  factory _$DashboardSummaryCopyWith(_DashboardSummary value, $Res Function(_DashboardSummary) _then) = __$DashboardSummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalMembers, int activeMembers, int activeSubscriptions, int expiringSoonSubscriptions, int expiredSubscriptions, int todayCheckIns
});




}
/// @nodoc
class __$DashboardSummaryCopyWithImpl<$Res>
    implements _$DashboardSummaryCopyWith<$Res> {
  __$DashboardSummaryCopyWithImpl(this._self, this._then);

  final _DashboardSummary _self;
  final $Res Function(_DashboardSummary) _then;

/// Create a copy of DashboardSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalMembers = null,Object? activeMembers = null,Object? activeSubscriptions = null,Object? expiringSoonSubscriptions = null,Object? expiredSubscriptions = null,Object? todayCheckIns = null,}) {
  return _then(_DashboardSummary(
totalMembers: null == totalMembers ? _self.totalMembers : totalMembers // ignore: cast_nullable_to_non_nullable
as int,activeMembers: null == activeMembers ? _self.activeMembers : activeMembers // ignore: cast_nullable_to_non_nullable
as int,activeSubscriptions: null == activeSubscriptions ? _self.activeSubscriptions : activeSubscriptions // ignore: cast_nullable_to_non_nullable
as int,expiringSoonSubscriptions: null == expiringSoonSubscriptions ? _self.expiringSoonSubscriptions : expiringSoonSubscriptions // ignore: cast_nullable_to_non_nullable
as int,expiredSubscriptions: null == expiredSubscriptions ? _self.expiredSubscriptions : expiredSubscriptions // ignore: cast_nullable_to_non_nullable
as int,todayCheckIns: null == todayCheckIns ? _self.todayCheckIns : todayCheckIns // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
