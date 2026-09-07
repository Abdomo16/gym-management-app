// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_expiring_subscription.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardExpiringSubscription {

 Subscription get subscription; String get memberName; String? get memberCode; String? get planName; int get remainingDays;
/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardExpiringSubscriptionCopyWith<DashboardExpiringSubscription> get copyWith => _$DashboardExpiringSubscriptionCopyWithImpl<DashboardExpiringSubscription>(this as DashboardExpiringSubscription, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardExpiringSubscription&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays));
}


@override
int get hashCode => Object.hash(runtimeType,subscription,memberName,memberCode,planName,remainingDays);

@override
String toString() {
  return 'DashboardExpiringSubscription(subscription: $subscription, memberName: $memberName, memberCode: $memberCode, planName: $planName, remainingDays: $remainingDays)';
}


}

/// @nodoc
abstract mixin class $DashboardExpiringSubscriptionCopyWith<$Res>  {
  factory $DashboardExpiringSubscriptionCopyWith(DashboardExpiringSubscription value, $Res Function(DashboardExpiringSubscription) _then) = _$DashboardExpiringSubscriptionCopyWithImpl;
@useResult
$Res call({
 Subscription subscription, String memberName, String? memberCode, String? planName, int remainingDays
});


$SubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class _$DashboardExpiringSubscriptionCopyWithImpl<$Res>
    implements $DashboardExpiringSubscriptionCopyWith<$Res> {
  _$DashboardExpiringSubscriptionCopyWithImpl(this._self, this._then);

  final DashboardExpiringSubscription _self;
  final $Res Function(DashboardExpiringSubscription) _then;

/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? subscription = null,Object? memberName = null,Object? memberCode = freezed,Object? planName = freezed,Object? remainingDays = null,}) {
  return _then(_self.copyWith(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as Subscription,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,remainingDays: null == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionCopyWith<$Res> get subscription {
  
  return $SubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardExpiringSubscription].
extension DashboardExpiringSubscriptionPatterns on DashboardExpiringSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardExpiringSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardExpiringSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardExpiringSubscription value)  $default,){
final _that = this;
switch (_that) {
case _DashboardExpiringSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardExpiringSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardExpiringSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Subscription subscription,  String memberName,  String? memberCode,  String? planName,  int remainingDays)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardExpiringSubscription() when $default != null:
return $default(_that.subscription,_that.memberName,_that.memberCode,_that.planName,_that.remainingDays);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Subscription subscription,  String memberName,  String? memberCode,  String? planName,  int remainingDays)  $default,) {final _that = this;
switch (_that) {
case _DashboardExpiringSubscription():
return $default(_that.subscription,_that.memberName,_that.memberCode,_that.planName,_that.remainingDays);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Subscription subscription,  String memberName,  String? memberCode,  String? planName,  int remainingDays)?  $default,) {final _that = this;
switch (_that) {
case _DashboardExpiringSubscription() when $default != null:
return $default(_that.subscription,_that.memberName,_that.memberCode,_that.planName,_that.remainingDays);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardExpiringSubscription implements DashboardExpiringSubscription {
  const _DashboardExpiringSubscription({required this.subscription, required this.memberName, this.memberCode, this.planName, required this.remainingDays});
  

@override final  Subscription subscription;
@override final  String memberName;
@override final  String? memberCode;
@override final  String? planName;
@override final  int remainingDays;

/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardExpiringSubscriptionCopyWith<_DashboardExpiringSubscription> get copyWith => __$DashboardExpiringSubscriptionCopyWithImpl<_DashboardExpiringSubscription>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardExpiringSubscription&&(identical(other.subscription, subscription) || other.subscription == subscription)&&(identical(other.memberName, memberName) || other.memberName == memberName)&&(identical(other.memberCode, memberCode) || other.memberCode == memberCode)&&(identical(other.planName, planName) || other.planName == planName)&&(identical(other.remainingDays, remainingDays) || other.remainingDays == remainingDays));
}


@override
int get hashCode => Object.hash(runtimeType,subscription,memberName,memberCode,planName,remainingDays);

@override
String toString() {
  return 'DashboardExpiringSubscription(subscription: $subscription, memberName: $memberName, memberCode: $memberCode, planName: $planName, remainingDays: $remainingDays)';
}


}

/// @nodoc
abstract mixin class _$DashboardExpiringSubscriptionCopyWith<$Res> implements $DashboardExpiringSubscriptionCopyWith<$Res> {
  factory _$DashboardExpiringSubscriptionCopyWith(_DashboardExpiringSubscription value, $Res Function(_DashboardExpiringSubscription) _then) = __$DashboardExpiringSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 Subscription subscription, String memberName, String? memberCode, String? planName, int remainingDays
});


@override $SubscriptionCopyWith<$Res> get subscription;

}
/// @nodoc
class __$DashboardExpiringSubscriptionCopyWithImpl<$Res>
    implements _$DashboardExpiringSubscriptionCopyWith<$Res> {
  __$DashboardExpiringSubscriptionCopyWithImpl(this._self, this._then);

  final _DashboardExpiringSubscription _self;
  final $Res Function(_DashboardExpiringSubscription) _then;

/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? subscription = null,Object? memberName = null,Object? memberCode = freezed,Object? planName = freezed,Object? remainingDays = null,}) {
  return _then(_DashboardExpiringSubscription(
subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as Subscription,memberName: null == memberName ? _self.memberName : memberName // ignore: cast_nullable_to_non_nullable
as String,memberCode: freezed == memberCode ? _self.memberCode : memberCode // ignore: cast_nullable_to_non_nullable
as String?,planName: freezed == planName ? _self.planName : planName // ignore: cast_nullable_to_non_nullable
as String?,remainingDays: null == remainingDays ? _self.remainingDays : remainingDays // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of DashboardExpiringSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SubscriptionCopyWith<$Res> get subscription {
  
  return $SubscriptionCopyWith<$Res>(_self.subscription, (value) {
    return _then(_self.copyWith(subscription: value));
  });
}
}

// dart format on
