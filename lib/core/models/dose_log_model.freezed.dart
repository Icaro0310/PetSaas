// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dose_log_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DoseLogModel {

 String get id; String get medicationId; String get petId; DateTime get scheduledTime; DateTime? get givenAt; String? get givenBy; DoseStatus get status; String? get photoUrl; String? get notes; DateTime? get createdAt;
/// Create a copy of DoseLogModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DoseLogModelCopyWith<DoseLogModel> get copyWith => _$DoseLogModelCopyWithImpl<DoseLogModel>(this as DoseLogModel, _$identity);

  /// Serializes this DoseLogModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DoseLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.medicationId, medicationId) || other.medicationId == medicationId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.givenAt, givenAt) || other.givenAt == givenAt)&&(identical(other.givenBy, givenBy) || other.givenBy == givenBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicationId,petId,scheduledTime,givenAt,givenBy,status,photoUrl,notes,createdAt);

@override
String toString() {
  return 'DoseLogModel(id: $id, medicationId: $medicationId, petId: $petId, scheduledTime: $scheduledTime, givenAt: $givenAt, givenBy: $givenBy, status: $status, photoUrl: $photoUrl, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DoseLogModelCopyWith<$Res>  {
  factory $DoseLogModelCopyWith(DoseLogModel value, $Res Function(DoseLogModel) _then) = _$DoseLogModelCopyWithImpl;
@useResult
$Res call({
 String id, String medicationId, String petId, DateTime scheduledTime, DateTime? givenAt, String? givenBy, DoseStatus status, String? photoUrl, String? notes, DateTime? createdAt
});




}
/// @nodoc
class _$DoseLogModelCopyWithImpl<$Res>
    implements $DoseLogModelCopyWith<$Res> {
  _$DoseLogModelCopyWithImpl(this._self, this._then);

  final DoseLogModel _self;
  final $Res Function(DoseLogModel) _then;

/// Create a copy of DoseLogModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? medicationId = null,Object? petId = null,Object? scheduledTime = null,Object? givenAt = freezed,Object? givenBy = freezed,Object? status = null,Object? photoUrl = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(DoseLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicationId: null == medicationId ? _self.medicationId : medicationId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,givenAt: freezed == givenAt ? _self.givenAt : givenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,givenBy: freezed == givenBy ? _self.givenBy : givenBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DoseStatus,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DoseLogModel].
extension DoseLogModelPatterns on DoseLogModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DoseLogModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DoseLogModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DoseLogModel value)  $default,){
final _that = this;
switch (_that) {
case _DoseLogModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DoseLogModel value)?  $default,){
final _that = this;
switch (_that) {
case _DoseLogModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String medicationId,  String petId,  DateTime scheduledTime,  DateTime? givenAt,  String? givenBy,  DoseStatus status,  String? photoUrl,  String? notes,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DoseLogModel() when $default != null:
return $default(_that.id,_that.medicationId,_that.petId,_that.scheduledTime,_that.givenAt,_that.givenBy,_that.status,_that.photoUrl,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String medicationId,  String petId,  DateTime scheduledTime,  DateTime? givenAt,  String? givenBy,  DoseStatus status,  String? photoUrl,  String? notes,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DoseLogModel():
return $default(_that.id,_that.medicationId,_that.petId,_that.scheduledTime,_that.givenAt,_that.givenBy,_that.status,_that.photoUrl,_that.notes,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String medicationId,  String petId,  DateTime scheduledTime,  DateTime? givenAt,  String? givenBy,  DoseStatus status,  String? photoUrl,  String? notes,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DoseLogModel() when $default != null:
return $default(_that.id,_that.medicationId,_that.petId,_that.scheduledTime,_that.givenAt,_that.givenBy,_that.status,_that.photoUrl,_that.notes,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DoseLogModel implements DoseLogModel {
  const _DoseLogModel({required this.id, required this.medicationId, required this.petId, required this.scheduledTime, this.givenAt, this.givenBy, this.status = DoseStatus.pending, this.photoUrl, this.notes, this.createdAt});
  factory _DoseLogModel.fromJson(Map<String, dynamic> json) => _$DoseLogModelFromJson(json);

@override final  String id;
@override final  String medicationId;
@override final  String petId;
@override final  DateTime scheduledTime;
@override final  DateTime? givenAt;
@override final  String? givenBy;
@override@JsonKey() final  DoseStatus status;
@override final  String? photoUrl;
@override final  String? notes;
@override final  DateTime? createdAt;

/// Create a copy of DoseLogModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DoseLogModelCopyWith<_DoseLogModel> get copyWith => __$DoseLogModelCopyWithImpl<_DoseLogModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DoseLogModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DoseLogModel&&(identical(other.id, id) || other.id == id)&&(identical(other.medicationId, medicationId) || other.medicationId == medicationId)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.scheduledTime, scheduledTime) || other.scheduledTime == scheduledTime)&&(identical(other.givenAt, givenAt) || other.givenAt == givenAt)&&(identical(other.givenBy, givenBy) || other.givenBy == givenBy)&&(identical(other.status, status) || other.status == status)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,medicationId,petId,scheduledTime,givenAt,givenBy,status,photoUrl,notes,createdAt);

@override
String toString() {
  return 'DoseLogModel(id: $id, medicationId: $medicationId, petId: $petId, scheduledTime: $scheduledTime, givenAt: $givenAt, givenBy: $givenBy, status: $status, photoUrl: $photoUrl, notes: $notes, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DoseLogModelCopyWith<$Res> implements $DoseLogModelCopyWith<$Res> {
  factory _$DoseLogModelCopyWith(_DoseLogModel value, $Res Function(_DoseLogModel) _then) = __$DoseLogModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String medicationId, String petId, DateTime scheduledTime, DateTime? givenAt, String? givenBy, DoseStatus status, String? photoUrl, String? notes, DateTime? createdAt
});




}
/// @nodoc
class __$DoseLogModelCopyWithImpl<$Res>
    implements _$DoseLogModelCopyWith<$Res> {
  __$DoseLogModelCopyWithImpl(this._self, this._then);

  final _DoseLogModel _self;
  final $Res Function(_DoseLogModel) _then;

/// Create a copy of DoseLogModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? medicationId = null,Object? petId = null,Object? scheduledTime = null,Object? givenAt = freezed,Object? givenBy = freezed,Object? status = null,Object? photoUrl = freezed,Object? notes = freezed,Object? createdAt = freezed,}) {
  return _then(_DoseLogModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,medicationId: null == medicationId ? _self.medicationId : medicationId // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,scheduledTime: null == scheduledTime ? _self.scheduledTime : scheduledTime // ignore: cast_nullable_to_non_nullable
as DateTime,givenAt: freezed == givenAt ? _self.givenAt : givenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,givenBy: freezed == givenBy ? _self.givenBy : givenBy // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as DoseStatus,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
