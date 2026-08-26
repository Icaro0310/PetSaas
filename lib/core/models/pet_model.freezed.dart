// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PetModel {

 String get id; String get ownerId; String get name; PetSpecies get species; String? get breed; DateTime? get birthDate; double? get weightKg; String? get color; String? get photoUrl; String? get description; String? get emergencyInfo; String? get allergies; String? get criticalMeds; String? get warnings; String? get microchipId; String? get vetName; String? get vetPhone; bool get isLost; DateTime? get lostAt; String? get qrCodeUuid; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of PetModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PetModelCopyWith<PetModel> get copyWith => _$PetModelCopyWithImpl<PetModel>(this as PetModel, _$identity);

  /// Serializes this PetModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.color, color) || other.color == color)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.emergencyInfo, emergencyInfo) || other.emergencyInfo == emergencyInfo)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.criticalMeds, criticalMeds) || other.criticalMeds == criticalMeds)&&(identical(other.warnings, warnings) || other.warnings == warnings)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.vetName, vetName) || other.vetName == vetName)&&(identical(other.vetPhone, vetPhone) || other.vetPhone == vetPhone)&&(identical(other.isLost, isLost) || other.isLost == isLost)&&(identical(other.lostAt, lostAt) || other.lostAt == lostAt)&&(identical(other.qrCodeUuid, qrCodeUuid) || other.qrCodeUuid == qrCodeUuid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ownerId,name,species,breed,birthDate,weightKg,color,photoUrl,description,emergencyInfo,allergies,criticalMeds,warnings,microchipId,vetName,vetPhone,isLost,lostAt,qrCodeUuid,createdAt,updatedAt]);

@override
String toString() {
  return 'PetModel(id: $id, ownerId: $ownerId, name: $name, species: $species, breed: $breed, birthDate: $birthDate, weightKg: $weightKg, color: $color, photoUrl: $photoUrl, description: $description, emergencyInfo: $emergencyInfo, allergies: $allergies, criticalMeds: $criticalMeds, warnings: $warnings, microchipId: $microchipId, vetName: $vetName, vetPhone: $vetPhone, isLost: $isLost, lostAt: $lostAt, qrCodeUuid: $qrCodeUuid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $PetModelCopyWith<$Res>  {
  factory $PetModelCopyWith(PetModel value, $Res Function(PetModel) _then) = _$PetModelCopyWithImpl;
@useResult
$Res call({
 String id, String ownerId, String name, PetSpecies species, String? breed, DateTime? birthDate, double? weightKg, String? color, String? photoUrl, String? description, String? emergencyInfo, String? allergies, String? criticalMeds, String? warnings, String? microchipId, String? vetName, String? vetPhone, bool isLost, DateTime? lostAt, String? qrCodeUuid, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$PetModelCopyWithImpl<$Res>
    implements $PetModelCopyWith<$Res> {
  _$PetModelCopyWithImpl(this._self, this._then);

  final PetModel _self;
  final $Res Function(PetModel) _then;

/// Create a copy of PetModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? species = null,Object? breed = freezed,Object? birthDate = freezed,Object? weightKg = freezed,Object? color = freezed,Object? photoUrl = freezed,Object? description = freezed,Object? emergencyInfo = freezed,Object? allergies = freezed,Object? criticalMeds = freezed,Object? warnings = freezed,Object? microchipId = freezed,Object? vetName = freezed,Object? vetPhone = freezed,Object? isLost = null,Object? lostAt = freezed,Object? qrCodeUuid = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(PetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emergencyInfo: freezed == emergencyInfo ? _self.emergencyInfo : emergencyInfo // ignore: cast_nullable_to_non_nullable
as String?,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,criticalMeds: freezed == criticalMeds ? _self.criticalMeds : criticalMeds // ignore: cast_nullable_to_non_nullable
as String?,warnings: freezed == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,vetName: freezed == vetName ? _self.vetName : vetName // ignore: cast_nullable_to_non_nullable
as String?,vetPhone: freezed == vetPhone ? _self.vetPhone : vetPhone // ignore: cast_nullable_to_non_nullable
as String?,isLost: null == isLost ? _self.isLost : isLost // ignore: cast_nullable_to_non_nullable
as bool,lostAt: freezed == lostAt ? _self.lostAt : lostAt // ignore: cast_nullable_to_non_nullable
as DateTime?,qrCodeUuid: freezed == qrCodeUuid ? _self.qrCodeUuid : qrCodeUuid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PetModel].
extension PetModelPatterns on PetModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PetModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PetModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PetModel value)  $default,){
final _that = this;
switch (_that) {
case _PetModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PetModel value)?  $default,){
final _that = this;
switch (_that) {
case _PetModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  PetSpecies species,  String? breed,  DateTime? birthDate,  double? weightKg,  String? color,  String? photoUrl,  String? description,  String? emergencyInfo,  String? allergies,  String? criticalMeds,  String? warnings,  String? microchipId,  String? vetName,  String? vetPhone,  bool isLost,  DateTime? lostAt,  String? qrCodeUuid,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PetModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.birthDate,_that.weightKg,_that.color,_that.photoUrl,_that.description,_that.emergencyInfo,_that.allergies,_that.criticalMeds,_that.warnings,_that.microchipId,_that.vetName,_that.vetPhone,_that.isLost,_that.lostAt,_that.qrCodeUuid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String ownerId,  String name,  PetSpecies species,  String? breed,  DateTime? birthDate,  double? weightKg,  String? color,  String? photoUrl,  String? description,  String? emergencyInfo,  String? allergies,  String? criticalMeds,  String? warnings,  String? microchipId,  String? vetName,  String? vetPhone,  bool isLost,  DateTime? lostAt,  String? qrCodeUuid,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _PetModel():
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.birthDate,_that.weightKg,_that.color,_that.photoUrl,_that.description,_that.emergencyInfo,_that.allergies,_that.criticalMeds,_that.warnings,_that.microchipId,_that.vetName,_that.vetPhone,_that.isLost,_that.lostAt,_that.qrCodeUuid,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String ownerId,  String name,  PetSpecies species,  String? breed,  DateTime? birthDate,  double? weightKg,  String? color,  String? photoUrl,  String? description,  String? emergencyInfo,  String? allergies,  String? criticalMeds,  String? warnings,  String? microchipId,  String? vetName,  String? vetPhone,  bool isLost,  DateTime? lostAt,  String? qrCodeUuid,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _PetModel() when $default != null:
return $default(_that.id,_that.ownerId,_that.name,_that.species,_that.breed,_that.birthDate,_that.weightKg,_that.color,_that.photoUrl,_that.description,_that.emergencyInfo,_that.allergies,_that.criticalMeds,_that.warnings,_that.microchipId,_that.vetName,_that.vetPhone,_that.isLost,_that.lostAt,_that.qrCodeUuid,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PetModel implements PetModel {
  const _PetModel({required this.id, required this.ownerId, required this.name, required this.species, this.breed, this.birthDate, this.weightKg, this.color, this.photoUrl, this.description, this.emergencyInfo, this.allergies, this.criticalMeds, this.warnings, this.microchipId, this.vetName, this.vetPhone, this.isLost = false, this.lostAt, this.qrCodeUuid, this.createdAt, this.updatedAt});
  factory _PetModel.fromJson(Map<String, dynamic> json) => _$PetModelFromJson(json);

@override final  String id;
@override final  String ownerId;
@override final  String name;
@override final  PetSpecies species;
@override final  String? breed;
@override final  DateTime? birthDate;
@override final  double? weightKg;
@override final  String? color;
@override final  String? photoUrl;
@override final  String? description;
@override final  String? emergencyInfo;
@override final  String? allergies;
@override final  String? criticalMeds;
@override final  String? warnings;
@override final  String? microchipId;
@override final  String? vetName;
@override final  String? vetPhone;
@override@JsonKey() final  bool isLost;
@override final  DateTime? lostAt;
@override final  String? qrCodeUuid;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of PetModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PetModelCopyWith<_PetModel> get copyWith => __$PetModelCopyWithImpl<_PetModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PetModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PetModel&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.name, name) || other.name == name)&&(identical(other.species, species) || other.species == species)&&(identical(other.breed, breed) || other.breed == breed)&&(identical(other.birthDate, birthDate) || other.birthDate == birthDate)&&(identical(other.weightKg, weightKg) || other.weightKg == weightKg)&&(identical(other.color, color) || other.color == color)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.description, description) || other.description == description)&&(identical(other.emergencyInfo, emergencyInfo) || other.emergencyInfo == emergencyInfo)&&(identical(other.allergies, allergies) || other.allergies == allergies)&&(identical(other.criticalMeds, criticalMeds) || other.criticalMeds == criticalMeds)&&(identical(other.warnings, warnings) || other.warnings == warnings)&&(identical(other.microchipId, microchipId) || other.microchipId == microchipId)&&(identical(other.vetName, vetName) || other.vetName == vetName)&&(identical(other.vetPhone, vetPhone) || other.vetPhone == vetPhone)&&(identical(other.isLost, isLost) || other.isLost == isLost)&&(identical(other.lostAt, lostAt) || other.lostAt == lostAt)&&(identical(other.qrCodeUuid, qrCodeUuid) || other.qrCodeUuid == qrCodeUuid)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,ownerId,name,species,breed,birthDate,weightKg,color,photoUrl,description,emergencyInfo,allergies,criticalMeds,warnings,microchipId,vetName,vetPhone,isLost,lostAt,qrCodeUuid,createdAt,updatedAt]);

@override
String toString() {
  return 'PetModel(id: $id, ownerId: $ownerId, name: $name, species: $species, breed: $breed, birthDate: $birthDate, weightKg: $weightKg, color: $color, photoUrl: $photoUrl, description: $description, emergencyInfo: $emergencyInfo, allergies: $allergies, criticalMeds: $criticalMeds, warnings: $warnings, microchipId: $microchipId, vetName: $vetName, vetPhone: $vetPhone, isLost: $isLost, lostAt: $lostAt, qrCodeUuid: $qrCodeUuid, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$PetModelCopyWith<$Res> implements $PetModelCopyWith<$Res> {
  factory _$PetModelCopyWith(_PetModel value, $Res Function(_PetModel) _then) = __$PetModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String ownerId, String name, PetSpecies species, String? breed, DateTime? birthDate, double? weightKg, String? color, String? photoUrl, String? description, String? emergencyInfo, String? allergies, String? criticalMeds, String? warnings, String? microchipId, String? vetName, String? vetPhone, bool isLost, DateTime? lostAt, String? qrCodeUuid, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$PetModelCopyWithImpl<$Res>
    implements _$PetModelCopyWith<$Res> {
  __$PetModelCopyWithImpl(this._self, this._then);

  final _PetModel _self;
  final $Res Function(_PetModel) _then;

/// Create a copy of PetModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? name = null,Object? species = null,Object? breed = freezed,Object? birthDate = freezed,Object? weightKg = freezed,Object? color = freezed,Object? photoUrl = freezed,Object? description = freezed,Object? emergencyInfo = freezed,Object? allergies = freezed,Object? criticalMeds = freezed,Object? warnings = freezed,Object? microchipId = freezed,Object? vetName = freezed,Object? vetPhone = freezed,Object? isLost = null,Object? lostAt = freezed,Object? qrCodeUuid = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_PetModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,species: null == species ? _self.species : species // ignore: cast_nullable_to_non_nullable
as PetSpecies,breed: freezed == breed ? _self.breed : breed // ignore: cast_nullable_to_non_nullable
as String?,birthDate: freezed == birthDate ? _self.birthDate : birthDate // ignore: cast_nullable_to_non_nullable
as DateTime?,weightKg: freezed == weightKg ? _self.weightKg : weightKg // ignore: cast_nullable_to_non_nullable
as double?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,emergencyInfo: freezed == emergencyInfo ? _self.emergencyInfo : emergencyInfo // ignore: cast_nullable_to_non_nullable
as String?,allergies: freezed == allergies ? _self.allergies : allergies // ignore: cast_nullable_to_non_nullable
as String?,criticalMeds: freezed == criticalMeds ? _self.criticalMeds : criticalMeds // ignore: cast_nullable_to_non_nullable
as String?,warnings: freezed == warnings ? _self.warnings : warnings // ignore: cast_nullable_to_non_nullable
as String?,microchipId: freezed == microchipId ? _self.microchipId : microchipId // ignore: cast_nullable_to_non_nullable
as String?,vetName: freezed == vetName ? _self.vetName : vetName // ignore: cast_nullable_to_non_nullable
as String?,vetPhone: freezed == vetPhone ? _self.vetPhone : vetPhone // ignore: cast_nullable_to_non_nullable
as String?,isLost: null == isLost ? _self.isLost : isLost // ignore: cast_nullable_to_non_nullable
as bool,lostAt: freezed == lostAt ? _self.lostAt : lostAt // ignore: cast_nullable_to_non_nullable
as DateTime?,qrCodeUuid: freezed == qrCodeUuid ? _self.qrCodeUuid : qrCodeUuid // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
