// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order_tracking.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TrackingLocationSample {

 double get latitude; double get longitude; double? get accuracyMeters; double? get headingDegrees; double? get speedMps; DateTime get capturedAt; DateTime get receivedAt;
/// Create a copy of TrackingLocationSample
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingLocationSampleCopyWith<TrackingLocationSample> get copyWith => _$TrackingLocationSampleCopyWithImpl<TrackingLocationSample>(this as TrackingLocationSample, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrackingLocationSample;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingLocationSample&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude)&&(identical(other.accuracyMeters, _this.accuracyMeters) || other.accuracyMeters == _this.accuracyMeters)&&(identical(other.headingDegrees, _this.headingDegrees) || other.headingDegrees == _this.headingDegrees)&&(identical(other.speedMps, _this.speedMps) || other.speedMps == _this.speedMps)&&(identical(other.capturedAt, _this.capturedAt) || other.capturedAt == _this.capturedAt)&&(identical(other.receivedAt, _this.receivedAt) || other.receivedAt == _this.receivedAt));
}


@override
int get hashCode {
  final _this = this as TrackingLocationSample;
  return Object.hash(runtimeType,_this.latitude,_this.longitude,_this.accuracyMeters,_this.headingDegrees,_this.speedMps,_this.capturedAt,_this.receivedAt);
}

@override
String toString() {
  final _this = this as TrackingLocationSample;
  return 'TrackingLocationSample(latitude: ${_this.latitude}, longitude: ${_this.longitude}, accuracyMeters: ${_this.accuracyMeters}, headingDegrees: ${_this.headingDegrees}, speedMps: ${_this.speedMps}, capturedAt: ${_this.capturedAt}, receivedAt: ${_this.receivedAt})';
}


}

/// @nodoc
abstract mixin class $TrackingLocationSampleCopyWith<$Res>  {
  factory $TrackingLocationSampleCopyWith(TrackingLocationSample value, $Res Function(TrackingLocationSample) _then) = _$TrackingLocationSampleCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, double? accuracyMeters, double? headingDegrees, double? speedMps, DateTime capturedAt, DateTime receivedAt
});




}
/// @nodoc
class _$TrackingLocationSampleCopyWithImpl<$Res>
    implements $TrackingLocationSampleCopyWith<$Res> {
  _$TrackingLocationSampleCopyWithImpl(this._self, this._then);

  final TrackingLocationSample _self;
  final $Res Function(TrackingLocationSample) _then;

/// Create a copy of TrackingLocationSample
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? accuracyMeters = freezed,Object? headingDegrees = freezed,Object? speedMps = freezed,Object? capturedAt = null,Object? receivedAt = null,}) {
  return _then(TrackingLocationSample(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyMeters: freezed == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,headingDegrees: freezed == headingDegrees ? _self.headingDegrees : headingDegrees // ignore: cast_nullable_to_non_nullable
as double?,speedMps: freezed == speedMps ? _self.speedMps : speedMps // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingLocationSample].
extension TrackingLocationSamplePatterns on TrackingLocationSample {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingLocationSample value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingLocationSample() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingLocationSample value)  $default,){
final _that = this;
switch (_that) {
case _TrackingLocationSample():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingLocationSample value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingLocationSample() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracyMeters,  double? headingDegrees,  double? speedMps,  DateTime capturedAt,  DateTime receivedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingLocationSample() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.headingDegrees,_that.speedMps,_that.capturedAt,_that.receivedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  double? accuracyMeters,  double? headingDegrees,  double? speedMps,  DateTime capturedAt,  DateTime receivedAt)  $default,) {final _that = this;
switch (_that) {
case _TrackingLocationSample():
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.headingDegrees,_that.speedMps,_that.capturedAt,_that.receivedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  double? accuracyMeters,  double? headingDegrees,  double? speedMps,  DateTime capturedAt,  DateTime receivedAt)?  $default,) {final _that = this;
switch (_that) {
case _TrackingLocationSample() when $default != null:
return $default(_that.latitude,_that.longitude,_that.accuracyMeters,_that.headingDegrees,_that.speedMps,_that.capturedAt,_that.receivedAt);case _:
  return null;

}
}

}

/// @nodoc


class _TrackingLocationSample implements TrackingLocationSample {
  const _TrackingLocationSample({required this.latitude, required this.longitude, this.accuracyMeters, this.headingDegrees, this.speedMps, required this.capturedAt, required this.receivedAt});
  

@override final  double latitude;
@override final  double longitude;
@override final  double? accuracyMeters;
@override final  double? headingDegrees;
@override final  double? speedMps;
@override final  DateTime capturedAt;
@override final  DateTime receivedAt;

/// Create a copy of TrackingLocationSample
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingLocationSampleCopyWith<_TrackingLocationSample> get copyWith => __$TrackingLocationSampleCopyWithImpl<_TrackingLocationSample>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingLocationSample&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.accuracyMeters, accuracyMeters) || other.accuracyMeters == accuracyMeters)&&(identical(other.headingDegrees, headingDegrees) || other.headingDegrees == headingDegrees)&&(identical(other.speedMps, speedMps) || other.speedMps == speedMps)&&(identical(other.capturedAt, capturedAt) || other.capturedAt == capturedAt)&&(identical(other.receivedAt, receivedAt) || other.receivedAt == receivedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latitude,longitude,accuracyMeters,headingDegrees,speedMps,capturedAt,receivedAt);
}

@override
String toString() {
    return 'TrackingLocationSample(latitude: $latitude, longitude: $longitude, accuracyMeters: $accuracyMeters, headingDegrees: $headingDegrees, speedMps: $speedMps, capturedAt: $capturedAt, receivedAt: $receivedAt)';
}


}

/// @nodoc
abstract mixin class _$TrackingLocationSampleCopyWith<$Res> implements $TrackingLocationSampleCopyWith<$Res> {
  factory _$TrackingLocationSampleCopyWith(_TrackingLocationSample value, $Res Function(_TrackingLocationSample) _then) = __$TrackingLocationSampleCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, double? accuracyMeters, double? headingDegrees, double? speedMps, DateTime capturedAt, DateTime receivedAt
});




}
/// @nodoc
class __$TrackingLocationSampleCopyWithImpl<$Res>
    implements _$TrackingLocationSampleCopyWith<$Res> {
  __$TrackingLocationSampleCopyWithImpl(this._self, this._then);

  final _TrackingLocationSample _self;
  final $Res Function(_TrackingLocationSample) _then;

/// Create a copy of TrackingLocationSample
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? accuracyMeters = freezed,Object? headingDegrees = freezed,Object? speedMps = freezed,Object? capturedAt = null,Object? receivedAt = null,}) {
  return _then(_TrackingLocationSample(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,accuracyMeters: freezed == accuracyMeters ? _self.accuracyMeters : accuracyMeters // ignore: cast_nullable_to_non_nullable
as double?,headingDegrees: freezed == headingDegrees ? _self.headingDegrees : headingDegrees // ignore: cast_nullable_to_non_nullable
as double?,speedMps: freezed == speedMps ? _self.speedMps : speedMps // ignore: cast_nullable_to_non_nullable
as double?,capturedAt: null == capturedAt ? _self.capturedAt : capturedAt // ignore: cast_nullable_to_non_nullable
as DateTime,receivedAt: null == receivedAt ? _self.receivedAt : receivedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$TrackingDestination {

 double get latitude; double get longitude;
/// Create a copy of TrackingDestination
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackingDestinationCopyWith<TrackingDestination> get copyWith => _$TrackingDestinationCopyWithImpl<TrackingDestination>(this as TrackingDestination, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as TrackingDestination;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrackingDestination&&(identical(other.latitude, _this.latitude) || other.latitude == _this.latitude)&&(identical(other.longitude, _this.longitude) || other.longitude == _this.longitude));
}


@override
int get hashCode {
  final _this = this as TrackingDestination;
  return Object.hash(runtimeType,_this.latitude,_this.longitude);
}

@override
String toString() {
  final _this = this as TrackingDestination;
  return 'TrackingDestination(latitude: ${_this.latitude}, longitude: ${_this.longitude})';
}


}

/// @nodoc
abstract mixin class $TrackingDestinationCopyWith<$Res>  {
  factory $TrackingDestinationCopyWith(TrackingDestination value, $Res Function(TrackingDestination) _then) = _$TrackingDestinationCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude
});




}
/// @nodoc
class _$TrackingDestinationCopyWithImpl<$Res>
    implements $TrackingDestinationCopyWith<$Res> {
  _$TrackingDestinationCopyWithImpl(this._self, this._then);

  final TrackingDestination _self;
  final $Res Function(TrackingDestination) _then;

/// Create a copy of TrackingDestination
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,}) {
  return _then(TrackingDestination(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TrackingDestination].
extension TrackingDestinationPatterns on TrackingDestination {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrackingDestination value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrackingDestination() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrackingDestination value)  $default,){
final _that = this;
switch (_that) {
case _TrackingDestination():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrackingDestination value)?  $default,){
final _that = this;
switch (_that) {
case _TrackingDestination() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrackingDestination() when $default != null:
return $default(_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude)  $default,) {final _that = this;
switch (_that) {
case _TrackingDestination():
return $default(_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude)?  $default,) {final _that = this;
switch (_that) {
case _TrackingDestination() when $default != null:
return $default(_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc


class _TrackingDestination implements TrackingDestination {
  const _TrackingDestination({required this.latitude, required this.longitude});
  

@override final  double latitude;
@override final  double longitude;

/// Create a copy of TrackingDestination
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackingDestinationCopyWith<_TrackingDestination> get copyWith => __$TrackingDestinationCopyWithImpl<_TrackingDestination>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrackingDestination&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}


@override
int get hashCode {
    return Object.hash(runtimeType,latitude,longitude);
}

@override
String toString() {
    return 'TrackingDestination(latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$TrackingDestinationCopyWith<$Res> implements $TrackingDestinationCopyWith<$Res> {
  factory _$TrackingDestinationCopyWith(_TrackingDestination value, $Res Function(_TrackingDestination) _then) = __$TrackingDestinationCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude
});




}
/// @nodoc
class __$TrackingDestinationCopyWithImpl<$Res>
    implements _$TrackingDestinationCopyWith<$Res> {
  __$TrackingDestinationCopyWithImpl(this._self, this._then);

  final _TrackingDestination _self;
  final $Res Function(_TrackingDestination) _then;

/// Create a copy of TrackingDestination
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,}) {
  return _then(_TrackingDestination(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

/// @nodoc
mixin _$OrderTracking {

 String get orderId; TrackingState get state; String? get driverName; String? get driverPhone; TrackingLocationSample? get location; int? get locationAgeSeconds; TrackingDestination? get destination; double? get distanceKm; int? get etaSeconds; String? get encodedPolyline;
/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderTrackingCopyWith<OrderTracking> get copyWith => _$OrderTrackingCopyWithImpl<OrderTracking>(this as OrderTracking, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as OrderTracking;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderTracking&&(identical(other.orderId, _this.orderId) || other.orderId == _this.orderId)&&(identical(other.state, _this.state) || other.state == _this.state)&&(identical(other.driverName, _this.driverName) || other.driverName == _this.driverName)&&(identical(other.driverPhone, _this.driverPhone) || other.driverPhone == _this.driverPhone)&&(identical(other.location, _this.location) || other.location == _this.location)&&(identical(other.locationAgeSeconds, _this.locationAgeSeconds) || other.locationAgeSeconds == _this.locationAgeSeconds)&&(identical(other.destination, _this.destination) || other.destination == _this.destination)&&(identical(other.distanceKm, _this.distanceKm) || other.distanceKm == _this.distanceKm)&&(identical(other.etaSeconds, _this.etaSeconds) || other.etaSeconds == _this.etaSeconds)&&(identical(other.encodedPolyline, _this.encodedPolyline) || other.encodedPolyline == _this.encodedPolyline));
}


@override
int get hashCode {
  final _this = this as OrderTracking;
  return Object.hash(runtimeType,_this.orderId,_this.state,_this.driverName,_this.driverPhone,_this.location,_this.locationAgeSeconds,_this.destination,_this.distanceKm,_this.etaSeconds,_this.encodedPolyline);
}

@override
String toString() {
  final _this = this as OrderTracking;
  return 'OrderTracking(orderId: ${_this.orderId}, state: ${_this.state}, driverName: ${_this.driverName}, driverPhone: ${_this.driverPhone}, location: ${_this.location}, locationAgeSeconds: ${_this.locationAgeSeconds}, destination: ${_this.destination}, distanceKm: ${_this.distanceKm}, etaSeconds: ${_this.etaSeconds}, encodedPolyline: ${_this.encodedPolyline})';
}


}

/// @nodoc
abstract mixin class $OrderTrackingCopyWith<$Res>  {
  factory $OrderTrackingCopyWith(OrderTracking value, $Res Function(OrderTracking) _then) = _$OrderTrackingCopyWithImpl;
@useResult
$Res call({
 String orderId, TrackingState state, String? driverName, String? driverPhone, TrackingLocationSample? location, int? locationAgeSeconds, TrackingDestination? destination, double? distanceKm, int? etaSeconds, String? encodedPolyline
});


$TrackingLocationSampleCopyWith<$Res>? get location;$TrackingDestinationCopyWith<$Res>? get destination;

}
/// @nodoc
class _$OrderTrackingCopyWithImpl<$Res>
    implements $OrderTrackingCopyWith<$Res> {
  _$OrderTrackingCopyWithImpl(this._self, this._then);

  final OrderTracking _self;
  final $Res Function(OrderTracking) _then;

/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? orderId = null,Object? state = null,Object? driverName = freezed,Object? driverPhone = freezed,Object? location = freezed,Object? locationAgeSeconds = freezed,Object? destination = freezed,Object? distanceKm = freezed,Object? etaSeconds = freezed,Object? encodedPolyline = freezed,}) {
  return _then(OrderTracking(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TrackingState,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as TrackingLocationSample?,locationAgeSeconds: freezed == locationAgeSeconds ? _self.locationAgeSeconds : locationAgeSeconds // ignore: cast_nullable_to_non_nullable
as int?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as TrackingDestination?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,etaSeconds: freezed == etaSeconds ? _self.etaSeconds : etaSeconds // ignore: cast_nullable_to_non_nullable
as int?,encodedPolyline: freezed == encodedPolyline ? _self.encodedPolyline : encodedPolyline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingLocationSampleCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $TrackingLocationSampleCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $TrackingDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [OrderTracking].
extension OrderTrackingPatterns on OrderTracking {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderTracking value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderTracking() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderTracking value)  $default,){
final _that = this;
switch (_that) {
case _OrderTracking():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderTracking value)?  $default,){
final _that = this;
switch (_that) {
case _OrderTracking() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String orderId,  TrackingState state,  String? driverName,  String? driverPhone,  TrackingLocationSample? location,  int? locationAgeSeconds,  TrackingDestination? destination,  double? distanceKm,  int? etaSeconds,  String? encodedPolyline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderTracking() when $default != null:
return $default(_that.orderId,_that.state,_that.driverName,_that.driverPhone,_that.location,_that.locationAgeSeconds,_that.destination,_that.distanceKm,_that.etaSeconds,_that.encodedPolyline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String orderId,  TrackingState state,  String? driverName,  String? driverPhone,  TrackingLocationSample? location,  int? locationAgeSeconds,  TrackingDestination? destination,  double? distanceKm,  int? etaSeconds,  String? encodedPolyline)  $default,) {final _that = this;
switch (_that) {
case _OrderTracking():
return $default(_that.orderId,_that.state,_that.driverName,_that.driverPhone,_that.location,_that.locationAgeSeconds,_that.destination,_that.distanceKm,_that.etaSeconds,_that.encodedPolyline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String orderId,  TrackingState state,  String? driverName,  String? driverPhone,  TrackingLocationSample? location,  int? locationAgeSeconds,  TrackingDestination? destination,  double? distanceKm,  int? etaSeconds,  String? encodedPolyline)?  $default,) {final _that = this;
switch (_that) {
case _OrderTracking() when $default != null:
return $default(_that.orderId,_that.state,_that.driverName,_that.driverPhone,_that.location,_that.locationAgeSeconds,_that.destination,_that.distanceKm,_that.etaSeconds,_that.encodedPolyline);case _:
  return null;

}
}

}

/// @nodoc


class _OrderTracking implements OrderTracking {
  const _OrderTracking({required this.orderId, required this.state, this.driverName, this.driverPhone, this.location, this.locationAgeSeconds, this.destination, this.distanceKm, this.etaSeconds, this.encodedPolyline});
  

@override final  String orderId;
@override final  TrackingState state;
@override final  String? driverName;
@override final  String? driverPhone;
@override final  TrackingLocationSample? location;
@override final  int? locationAgeSeconds;
@override final  TrackingDestination? destination;
@override final  double? distanceKm;
@override final  int? etaSeconds;
@override final  String? encodedPolyline;

/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderTrackingCopyWith<_OrderTracking> get copyWith => __$OrderTrackingCopyWithImpl<_OrderTracking>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderTracking&&(identical(other.orderId, orderId) || other.orderId == orderId)&&(identical(other.state, state) || other.state == state)&&(identical(other.driverName, driverName) || other.driverName == driverName)&&(identical(other.driverPhone, driverPhone) || other.driverPhone == driverPhone)&&(identical(other.location, location) || other.location == location)&&(identical(other.locationAgeSeconds, locationAgeSeconds) || other.locationAgeSeconds == locationAgeSeconds)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.etaSeconds, etaSeconds) || other.etaSeconds == etaSeconds)&&(identical(other.encodedPolyline, encodedPolyline) || other.encodedPolyline == encodedPolyline));
}


@override
int get hashCode {
    return Object.hash(runtimeType,orderId,state,driverName,driverPhone,location,locationAgeSeconds,destination,distanceKm,etaSeconds,encodedPolyline);
}

@override
String toString() {
    return 'OrderTracking(orderId: $orderId, state: $state, driverName: $driverName, driverPhone: $driverPhone, location: $location, locationAgeSeconds: $locationAgeSeconds, destination: $destination, distanceKm: $distanceKm, etaSeconds: $etaSeconds, encodedPolyline: $encodedPolyline)';
}


}

/// @nodoc
abstract mixin class _$OrderTrackingCopyWith<$Res> implements $OrderTrackingCopyWith<$Res> {
  factory _$OrderTrackingCopyWith(_OrderTracking value, $Res Function(_OrderTracking) _then) = __$OrderTrackingCopyWithImpl;
@override @useResult
$Res call({
 String orderId, TrackingState state, String? driverName, String? driverPhone, TrackingLocationSample? location, int? locationAgeSeconds, TrackingDestination? destination, double? distanceKm, int? etaSeconds, String? encodedPolyline
});


@override $TrackingLocationSampleCopyWith<$Res>? get location;@override $TrackingDestinationCopyWith<$Res>? get destination;

}
/// @nodoc
class __$OrderTrackingCopyWithImpl<$Res>
    implements _$OrderTrackingCopyWith<$Res> {
  __$OrderTrackingCopyWithImpl(this._self, this._then);

  final _OrderTracking _self;
  final $Res Function(_OrderTracking) _then;

/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? orderId = null,Object? state = null,Object? driverName = freezed,Object? driverPhone = freezed,Object? location = freezed,Object? locationAgeSeconds = freezed,Object? destination = freezed,Object? distanceKm = freezed,Object? etaSeconds = freezed,Object? encodedPolyline = freezed,}) {
  return _then(_OrderTracking(
orderId: null == orderId ? _self.orderId : orderId // ignore: cast_nullable_to_non_nullable
as String,state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as TrackingState,driverName: freezed == driverName ? _self.driverName : driverName // ignore: cast_nullable_to_non_nullable
as String?,driverPhone: freezed == driverPhone ? _self.driverPhone : driverPhone // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as TrackingLocationSample?,locationAgeSeconds: freezed == locationAgeSeconds ? _self.locationAgeSeconds : locationAgeSeconds // ignore: cast_nullable_to_non_nullable
as int?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as TrackingDestination?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,etaSeconds: freezed == etaSeconds ? _self.etaSeconds : etaSeconds // ignore: cast_nullable_to_non_nullable
as int?,encodedPolyline: freezed == encodedPolyline ? _self.encodedPolyline : encodedPolyline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingLocationSampleCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $TrackingLocationSampleCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of OrderTracking
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TrackingDestinationCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $TrackingDestinationCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
