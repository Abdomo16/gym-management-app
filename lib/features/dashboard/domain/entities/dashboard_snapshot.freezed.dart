// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_snapshot.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardSnapshot {

 DashboardSummary get summary; DateTime get businessDate; List<DashboardRecentCheckIn> get recentCheckIns; List<DashboardExpiringSubscription> get expiringSubscriptions;
/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardSnapshotCopyWith<DashboardSnapshot> get copyWith => _$DashboardSnapshotCopyWithImpl<DashboardSnapshot>(this as DashboardSnapshot, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardSnapshot&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&const DeepCollectionEquality().equals(other.recentCheckIns, recentCheckIns)&&const DeepCollectionEquality().equals(other.expiringSubscriptions, expiringSubscriptions));
}


@override
int get hashCode => Object.hash(runtimeType,summary,businessDate,const DeepCollectionEquality().hash(recentCheckIns),const DeepCollectionEquality().hash(expiringSubscriptions));

@override
String toString() {
  return 'DashboardSnapshot(summary: $summary, businessDate: $businessDate, recentCheckIns: $recentCheckIns, expiringSubscriptions: $expiringSubscriptions)';
}


}

/// @nodoc
abstract mixin class $DashboardSnapshotCopyWith<$Res>  {
  factory $DashboardSnapshotCopyWith(DashboardSnapshot value, $Res Function(DashboardSnapshot) _then) = _$DashboardSnapshotCopyWithImpl;
@useResult
$Res call({
 DashboardSummary summary, DateTime businessDate, List<DashboardRecentCheckIn> recentCheckIns, List<DashboardExpiringSubscription> expiringSubscriptions
});


$DashboardSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class _$DashboardSnapshotCopyWithImpl<$Res>
    implements $DashboardSnapshotCopyWith<$Res> {
  _$DashboardSnapshotCopyWithImpl(this._self, this._then);

  final DashboardSnapshot _self;
  final $Res Function(DashboardSnapshot) _then;

/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? summary = null,Object? businessDate = null,Object? recentCheckIns = null,Object? expiringSubscriptions = null,}) {
  return _then(_self.copyWith(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as DashboardSummary,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,recentCheckIns: null == recentCheckIns ? _self.recentCheckIns : recentCheckIns // ignore: cast_nullable_to_non_nullable
as List<DashboardRecentCheckIn>,expiringSubscriptions: null == expiringSubscriptions ? _self.expiringSubscriptions : expiringSubscriptions // ignore: cast_nullable_to_non_nullable
as List<DashboardExpiringSubscription>,
  ));
}
/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<$Res> get summary {
  
  return $DashboardSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardSnapshot].
extension DashboardSnapshotPatterns on DashboardSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _DashboardSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DashboardSummary summary,  DateTime businessDate,  List<DashboardRecentCheckIn> recentCheckIns,  List<DashboardExpiringSubscription> expiringSubscriptions)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardSnapshot() when $default != null:
return $default(_that.summary,_that.businessDate,_that.recentCheckIns,_that.expiringSubscriptions);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DashboardSummary summary,  DateTime businessDate,  List<DashboardRecentCheckIn> recentCheckIns,  List<DashboardExpiringSubscription> expiringSubscriptions)  $default,) {final _that = this;
switch (_that) {
case _DashboardSnapshot():
return $default(_that.summary,_that.businessDate,_that.recentCheckIns,_that.expiringSubscriptions);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DashboardSummary summary,  DateTime businessDate,  List<DashboardRecentCheckIn> recentCheckIns,  List<DashboardExpiringSubscription> expiringSubscriptions)?  $default,) {final _that = this;
switch (_that) {
case _DashboardSnapshot() when $default != null:
return $default(_that.summary,_that.businessDate,_that.recentCheckIns,_that.expiringSubscriptions);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardSnapshot implements DashboardSnapshot {
  const _DashboardSnapshot({required this.summary, required this.businessDate, required final  List<DashboardRecentCheckIn> recentCheckIns, required final  List<DashboardExpiringSubscription> expiringSubscriptions}): _recentCheckIns = recentCheckIns,_expiringSubscriptions = expiringSubscriptions;
  

@override final  DashboardSummary summary;
@override final  DateTime businessDate;
 final  List<DashboardRecentCheckIn> _recentCheckIns;
@override List<DashboardRecentCheckIn> get recentCheckIns {
  if (_recentCheckIns is EqualUnmodifiableListView) return _recentCheckIns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentCheckIns);
}

 final  List<DashboardExpiringSubscription> _expiringSubscriptions;
@override List<DashboardExpiringSubscription> get expiringSubscriptions {
  if (_expiringSubscriptions is EqualUnmodifiableListView) return _expiringSubscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expiringSubscriptions);
}


/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardSnapshotCopyWith<_DashboardSnapshot> get copyWith => __$DashboardSnapshotCopyWithImpl<_DashboardSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardSnapshot&&(identical(other.summary, summary) || other.summary == summary)&&(identical(other.businessDate, businessDate) || other.businessDate == businessDate)&&const DeepCollectionEquality().equals(other._recentCheckIns, _recentCheckIns)&&const DeepCollectionEquality().equals(other._expiringSubscriptions, _expiringSubscriptions));
}


@override
int get hashCode => Object.hash(runtimeType,summary,businessDate,const DeepCollectionEquality().hash(_recentCheckIns),const DeepCollectionEquality().hash(_expiringSubscriptions));

@override
String toString() {
  return 'DashboardSnapshot(summary: $summary, businessDate: $businessDate, recentCheckIns: $recentCheckIns, expiringSubscriptions: $expiringSubscriptions)';
}


}

/// @nodoc
abstract mixin class _$DashboardSnapshotCopyWith<$Res> implements $DashboardSnapshotCopyWith<$Res> {
  factory _$DashboardSnapshotCopyWith(_DashboardSnapshot value, $Res Function(_DashboardSnapshot) _then) = __$DashboardSnapshotCopyWithImpl;
@override @useResult
$Res call({
 DashboardSummary summary, DateTime businessDate, List<DashboardRecentCheckIn> recentCheckIns, List<DashboardExpiringSubscription> expiringSubscriptions
});


@override $DashboardSummaryCopyWith<$Res> get summary;

}
/// @nodoc
class __$DashboardSnapshotCopyWithImpl<$Res>
    implements _$DashboardSnapshotCopyWith<$Res> {
  __$DashboardSnapshotCopyWithImpl(this._self, this._then);

  final _DashboardSnapshot _self;
  final $Res Function(_DashboardSnapshot) _then;

/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? summary = null,Object? businessDate = null,Object? recentCheckIns = null,Object? expiringSubscriptions = null,}) {
  return _then(_DashboardSnapshot(
summary: null == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as DashboardSummary,businessDate: null == businessDate ? _self.businessDate : businessDate // ignore: cast_nullable_to_non_nullable
as DateTime,recentCheckIns: null == recentCheckIns ? _self._recentCheckIns : recentCheckIns // ignore: cast_nullable_to_non_nullable
as List<DashboardRecentCheckIn>,expiringSubscriptions: null == expiringSubscriptions ? _self._expiringSubscriptions : expiringSubscriptions // ignore: cast_nullable_to_non_nullable
as List<DashboardExpiringSubscription>,
  ));
}

/// Create a copy of DashboardSnapshot
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DashboardSummaryCopyWith<$Res> get summary {
  
  return $DashboardSummaryCopyWith<$Res>(_self.summary, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
