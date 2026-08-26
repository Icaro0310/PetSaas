// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medication_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MedicationModel {

 String get id; String get petId; String get name; String get dosage; String? get instructions; FrequencyType get frequencyType; int? get frequencyValue; List<String> get scheduleTimes; DateTime get startDate; DateTime? get endDate; bool get isActive; DateTime? get createdAt;
/// Create a copy of MedicationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MedicationModelCopyWith<MedicationModel> get copyWith => _$MedicationModelCopyWithImpl<MedicationModel>(this as MedicationModel, _$identity);

  /// Serializes this MedicationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.frequencyType, frequencyType) || other.frequencyType == frequencyType)&&(identical(other.frequencyValue, frequencyValue) || other.frequencyValue == frequencyValue)&&const DeepCollectionEquality().equals(other.scheduleTimes, scheduleTimes)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,name,dosage,instructions,frequencyType,frequencyValue,const DeepCollectionEquality().hash(scheduleTimes),startDate,endDate,isActive,createdAt);

@override
String toString() {
  return 'MedicationModel(id: $id, petId: $petId, name: $name, dosage: $dosage, instructions: $instructions, frequencyType: $frequencyType, frequencyValue: $frequencyValue, scheduleTimes: $scheduleTimes, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $MedicationModelCopyWith<$Res>  {
  factory $MedicationModelCopyWith(MedicationModel value, $Res Function(MedicationModel) _then) = _$MedicationModelCopyWithImpl;
@useResult
$Res call({
 String id, String petId, String name, String dosage, String? instructions, FrequencyType frequencyType, int? frequencyValue, List<String> scheduleTimes, DateTime startDate, DateTime? endDate, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class _$MedicationModelCopyWithImpl<$Res>
    implements $MedicationModelCopyWith<$Res> {
  _$MedicationModelCopyWithImpl(this._self, this._then);

  final MedicationModel _self;
  final $Res Function(MedicationModel) _then;

/// Create a copy of MedicationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? petId = null,Object? name = null,Object? dosage = null,Object? instructions = freezed,Object? frequencyType = null,Object? frequencyValue = freezed,Object? scheduleTimes = null,Object? startDate = null,Object? endDate = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(MedicationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,frequencyType: null == frequencyType ? _self.frequencyType : frequencyType // ignore: cast_nullable_to_non_nullable
as FrequencyType,frequencyValue: freezed == frequencyValue ? _self.frequencyValue : frequencyValue // ignore: cast_nullable_to_non_nullable
as int?,scheduleTimes: null == scheduleTimes ? _self.scheduleTimes : scheduleTimes // ignore: cast_nullable_to_non_nullable
as List<String>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [MedicationModel].
extension MedicationModelPatterns on MedicationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MedicationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MedicationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MedicationModel value)  $default,){
final _that = this;
switch (_that) {
case _MedicationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MedicationModel value)?  $default,){
final _that = this;
switch (_that) {
case _MedicationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String petId,  String name,  String dosage,  String? instructions,  FrequencyType frequencyType,  int? frequencyValue,  List<String> scheduleTimes,  DateTime startDate,  DateTime? endDate,  bool isActive,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MedicationModel() when $default != null:
return $default(_that.id,_that.petId,_that.name,_that.dosage,_that.instructions,_that.frequencyType,_that.frequencyValue,_that.scheduleTimes,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String petId,  String name,  String dosage,  String? instructions,  FrequencyType frequencyType,  int? frequencyValue,  List<String> scheduleTimes,  DateTime startDate,  DateTime? endDate,  bool isActive,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _MedicationModel():
return $default(_that.id,_that.petId,_that.name,_that.dosage,_that.instructions,_that.frequencyType,_that.frequencyValue,_that.scheduleTimes,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String petId,  String name,  String dosage,  String? instructions,  FrequencyType frequencyType,  int? frequencyValue,  List<String> scheduleTimes,  DateTime startDate,  DateTime? endDate,  bool isActive,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _MedicationModel() when $default != null:
return $default(_that.id,_that.petId,_that.name,_that.dosage,_that.instructions,_that.frequencyType,_that.frequencyValue,_that.scheduleTimes,_that.startDate,_that.endDate,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MedicationModel implements MedicationModel {
  const _MedicationModel({required this.id, required this.petId, required this.name, required this.dosage, this.instructions, required this.frequencyType, this.frequencyValue,  List<String> scheduleTimes = const [], required this.startDate, this.endDate, this.isActive = true, this.createdAt}): _scheduleTimes = scheduleTimes;
  factory _MedicationModel.fromJson(Map<String, dynamic> json) => _$MedicationModelFromJson(json);

@override final  String id;
@override final  String petId;
@override final  String name;
@override final  String dosage;
@override final  String? instructions;
@override final  FrequencyType frequencyType;
@override final  int? frequencyValue;
 final  List<String> _scheduleTimes;
@override@JsonKey() List<String> get scheduleTimes {
  if (_scheduleTimes is EqualUnmodifiableListView) return _scheduleTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_scheduleTimes);
}

@override final  DateTime startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  bool isActive;
@override final  DateTime? createdAt;

/// Create a copy of MedicationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MedicationModelCopyWith<_MedicationModel> get copyWith => __$MedicationModelCopyWithImpl<_MedicationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MedicationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MedicationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.petId, petId) || other.petId == petId)&&(identical(other.name, name) || other.name == name)&&(identical(other.dosage, dosage) || other.dosage == dosage)&&(identical(other.instructions, instructions) || other.instructions == instructions)&&(identical(other.frequencyType, frequencyType) || other.frequencyType == frequencyType)&&(identical(other.frequencyValue, frequencyValue) || other.frequencyValue == frequencyValue)&&const DeepCollectionEquality().equals(other._scheduleTimes, _scheduleTimes)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,petId,name,dosage,instructions,frequencyType,frequencyValue,const DeepCollectionEquality().hash(_scheduleTimes),startDate,endDate,isActive,createdAt);

@override
String toString() {
  return 'MedicationModel(id: $id, petId: $petId, name: $name, dosage: $dosage, instructions: $instructions, frequencyType: $frequencyType, frequencyValue: $frequencyValue, scheduleTimes: $scheduleTimes, startDate: $startDate, endDate: $endDate, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$MedicationModelCopyWith<$Res> implements $MedicationModelCopyWith<$Res> {
  factory _$MedicationModelCopyWith(_MedicationModel value, $Res Function(_MedicationModel) _then) = __$MedicationModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String petId, String name, String dosage, String? instructions, FrequencyType frequencyType, int? frequencyValue, List<String> scheduleTimes, DateTime startDate, DateTime? endDate, bool isActive, DateTime? createdAt
});




}
/// @nodoc
class __$MedicationModelCopyWithImpl<$Res>
    implements _$MedicationModelCopyWith<$Res> {
  __$MedicationModelCopyWithImpl(this._self, this._then);

  final _MedicationModel _self;
  final $Res Function(_MedicationModel) _then;

/// Create a copy of MedicationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? petId = null,Object? name = null,Object? dosage = null,Object? instructions = freezed,Object? frequencyType = null,Object? frequencyValue = freezed,Object? scheduleTimes = null,Object? startDate = null,Object? endDate = freezed,Object? isActive = null,Object? createdAt = freezed,}) {
  return _then(_MedicationModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,petId: null == petId ? _self.petId : petId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dosage: null == dosage ? _self.dosage : dosage // ignore: cast_nullable_to_non_nullable
as String,instructions: freezed == instructions ? _self.instructions : instructions // ignore: cast_nullable_to_non_nullable
as String?,frequencyType: null == frequencyType ? _self.frequencyType : frequencyType // ignore: cast_nullable_to_non_nullable
as FrequencyType,frequencyValue: freezed == frequencyValue ? _self.frequencyValue : frequencyValue // ignore: cast_nullable_to_non_nullable
as int?,scheduleTimes: null == scheduleTimes ? _self._scheduleTimes : scheduleTimes // ignore: cast_nullable_to_non_nullable
as List<String>,startDate: null == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
