// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'caregiver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CaregiverModel {

 String get id; String get petId; String get ownerId; String? get caregiverId; String get caregiverEmail; String? get inviteToken; CaregiverStatus get status; List<String> get permissions; DateTime? get invitedAt; DateTime? get acceptedAt; DateTime? get removedAt;
/// Create a copy of CaregiverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CaregiverModelCopyWith<CaregiverModel> get copyWith => _$CaregiverModelCopyWithImpl<CaregiverModel>(this as CaregiverModel, _$identity);

  /// Serializes this CaregiverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CaregiverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.caregiverId, caregiverId) || other.caregiverId == caregiverId)&&(identical(other.caregiverEmail, caregiverEmail) || other.caregiverEmail == caregiverEmail)&&(identical(other.inviteToken, inviteToken) || other.inviteToken == inviteToken)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.permissions, permissions)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.removedAt, removedAt) || other.removedAt == removedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,ownerId,caregiverId,caregiverEmail,inviteToken,status,const DeepCollectionEquality().hash(permissions),invitedAt,acceptedAt,removedAt);

@override
String toString() {
  return 'CaregiverModel(id: $id, petId: $petId, ownerId: $ownerId, caregiverId: $caregiverId, caregiverEmail: $caregiverEmail, inviteToken: $inviteToken, status: $status, permissions: $permissions, invitedAt: $invitedAt, acceptedAt: $acceptedAt, removedAt: $removedAt)';
}


}

/// @nodoc
abstract mixin class $CaregiverModelCopyWith<$Res>  {
  factory $CaregiverModelCopyWith(CaregiverModel value, $Res Function(CaregiverModel) _then) = _$CaregiverModelCopyWithImpl;
@useResult
$Res call({
 String id, String petId, String ownerId, String? caregiverId, String caregiverEmail, String? inviteToken, CaregiverStatus status, List<String> permissions, DateTime? invitedAt, DateTime? acceptedAt, DateTime? removedAt
});




}
/// @nodoc
class _$CaregiverModelCopyWithImpl<$Res>
    implements $CaregiverModelCopyWith<$Res> {
  _$CaregiverModelCopyWithImpl(this._self, this._then);

  final CaregiverModel _self;
  final $Res Function(CaregiverModel) _then;

/// Create a copy of CaregiverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? petId = null,Object? ownerId = null,Object? caregiverId = freezed,Object? caregiverEmail = null,Object? inviteToken = freezed,Object? status = null,Object? permissions = null,Object? invitedAt = freezed,Object? acceptedAt = freezed,Object? removedAt = freezed,}) {
  return _then(CaregiverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,caregiverId: freezed == caregiverId ? _self.caregiverId : caregiverId // ignore: cast_nullable_to_non_nullable
as String?,caregiverEmail: null == caregiverEmail ? _self.caregiverEmail : caregiverEmail // ignore: cast_nullable_to_non_nullable
as String,inviteToken: freezed == inviteToken ? _self.inviteToken : inviteToken // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaregiverStatus,permissions: null == permissions ? _self.permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CaregiverModel].
extension CaregiverModelPatterns on CaregiverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CaregiverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CaregiverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CaregiverModel value)  $default,){
final _that = this;
switch (_that) {
case _CaregiverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CaregiverModel value)?  $default,){
final _that = this;
switch (_that) {
case _CaregiverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String petId,  String ownerId,  String? caregiverId,  String caregiverEmail,  String? inviteToken,  CaregiverStatus status,  List<String> permissions,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? removedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CaregiverModel() when $default != null:
return $default(_that.id,_that.petId,_that.ownerId,_that.caregiverId,_that.caregiverEmail,_that.inviteToken,_that.status,_that.permissions,_that.invitedAt,_that.acceptedAt,_that.removedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String petId,  String ownerId,  String? caregiverId,  String caregiverEmail,  String? inviteToken,  CaregiverStatus status,  List<String> permissions,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? removedAt)  $default,) {final _that = this;
switch (_that) {
case _CaregiverModel():
return $default(_that.id,_that.petId,_that.ownerId,_that.caregiverId,_that.caregiverEmail,_that.inviteToken,_that.status,_that.permissions,_that.invitedAt,_that.acceptedAt,_that.removedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String petId,  String ownerId,  String? caregiverId,  String caregiverEmail,  String? inviteToken,  CaregiverStatus status,  List<String> permissions,  DateTime? invitedAt,  DateTime? acceptedAt,  DateTime? removedAt)?  $default,) {final _that = this;
switch (_that) {
case _CaregiverModel() when $default != null:
return $default(_that.id,_that.petId,_that.ownerId,_that.caregiverId,_that.caregiverEmail,_that.inviteToken,_that.status,_that.permissions,_that.invitedAt,_that.acceptedAt,_that.removedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CaregiverModel implements CaregiverModel {
  const _CaregiverModel({required this.id, required this.petId, required this.ownerId, this.caregiverId, required this.caregiverEmail, this.inviteToken, this.status = CaregiverStatus.pending,  List<String> permissions = const ['view', 'mark_dose'], this.invitedAt, this.acceptedAt, this.removedAt}): _permissions = permissions;
  factory _CaregiverModel.fromJson(Map<String, dynamic> json) => _$CaregiverModelFromJson(json);

@override final  String id;
@override final  String petId;
@override final  String ownerId;
@override final  String? caregiverId;
@override final  String caregiverEmail;
@override final  String? inviteToken;
@override@JsonKey() final  CaregiverStatus status;
 final  List<String> _permissions;
@override@JsonKey() List<String> get permissions {
  if (_permissions is EqualUnmodifiableListView) return _permissions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_permissions);
}

@override final  DateTime? invitedAt;
@override final  DateTime? acceptedAt;
@override final  DateTime? removedAt;

/// Create a copy of CaregiverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CaregiverModelCopyWith<_CaregiverModel> get copyWith => __$CaregiverModelCopyWithImpl<_CaregiverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CaregiverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CaregiverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.caregiverId, caregiverId) || other.caregiverId == caregiverId)&&(identical(other.caregiverEmail, caregiverEmail) || other.caregiverEmail == caregiverEmail)&&(identical(other.inviteToken, inviteToken) || other.inviteToken == inviteToken)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._permissions, _permissions)&&(identical(other.invitedAt, invitedAt) || other.invitedAt == invitedAt)&&(identical(other.acceptedAt, acceptedAt) || other.acceptedAt == acceptedAt)&&(identical(other.removedAt, removedAt) || other.removedAt == removedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,ownerId,caregiverId,caregiverEmail,inviteToken,status,const DeepCollectionEquality().hash(_permissions),invitedAt,acceptedAt,removedAt);

@override
String toString() {
  return 'CaregiverModel(id: $id, petId: $petId, ownerId: $ownerId, caregiverId: $caregiverId, caregiverEmail: $caregiverEmail, inviteToken: $inviteToken, status: $status, permissions: $permissions, invitedAt: $invitedAt, acceptedAt: $acceptedAt, removedAt: $removedAt)';
}


}

/// @nodoc
abstract mixin class _$CaregiverModelCopyWith<$Res> implements $CaregiverModelCopyWith<$Res> {
  factory _$CaregiverModelCopyWith(_CaregiverModel value, $Res Function(_CaregiverModel) _then) = __$CaregiverModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String petId, String ownerId, String? caregiverId, String caregiverEmail, String? inviteToken, CaregiverStatus status, List<String> permissions, DateTime? invitedAt, DateTime? acceptedAt, DateTime? removedAt
});




}
/// @nodoc
class __$CaregiverModelCopyWithImpl<$Res>
    implements _$CaregiverModelCopyWith<$Res> {
  __$CaregiverModelCopyWithImpl(this._self, this._then);

  final _CaregiverModel _self;
  final $Res Function(_CaregiverModel) _then;

/// Create a copy of CaregiverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? petId = null,Object? ownerId = null,Object? caregiverId = freezed,Object? caregiverEmail = null,Object? inviteToken = freezed,Object? status = null,Object? permissions = null,Object? invitedAt = freezed,Object? acceptedAt = freezed,Object? removedAt = freezed,}) {
  return _then(_CaregiverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,caregiverId: freezed == caregiverId ? _self.caregiverId : caregiverId // ignore: cast_nullable_to_non_nullable
as String?,caregiverEmail: null == caregiverEmail ? _self.caregiverEmail : caregiverEmail // ignore: cast_nullable_to_non_nullable
as String,inviteToken: freezed == inviteToken ? _self.inviteToken : inviteToken // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as CaregiverStatus,permissions: null == permissions ? _self._permissions : permissions // ignore: cast_nullable_to_non_nullable
as List<String>,invitedAt: freezed == invitedAt ? _self.invitedAt : invitedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,acceptedAt: freezed == acceptedAt ? _self.acceptedAt : acceptedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,removedAt: freezed == removedAt ? _self.removedAt : removedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
