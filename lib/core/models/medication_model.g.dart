// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    _MedicationModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      instructions: json['instructions'] as String?,
      frequencyType: $enumDecode(_$FrequencyTypeEnumMap, json['frequencyType']),
      frequencyValue: (json['frequencyValue'] as num?)?.toInt(),
      scheduleTimes:
          (json['scheduleTimes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MedicationModelToJson(_MedicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'petId': instance.petId,
      'name': instance.name,
      'dosage': instance.dosage,
      'instructions': instance.instructions,
      'frequencyType': _$FrequencyTypeEnumMap[instance.frequencyType]!,
      'frequencyValue': instance.frequencyValue,
      'scheduleTimes': instance.scheduleTimes,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$FrequencyTypeEnumMap = {
  FrequencyType.daily: 'daily',
  FrequencyType.weekly: 'weekly',
  FrequencyType.interval_hours: 'interval_hours',
  FrequencyType.as_needed: 'as_needed',
};
