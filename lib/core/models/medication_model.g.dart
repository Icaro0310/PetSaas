// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MedicationModel _$MedicationModelFromJson(Map<String, dynamic> json) =>
    _MedicationModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      instructions: json['instructions'] as String?,
      frequencyType: $enumDecode(
        _$FrequencyTypeEnumMap,
        json['frequency_type'],
      ),
      frequencyValue: (json['frequency_value'] as num?)?.toInt(),
      scheduleTimes:
          (json['schedule_times'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$MedicationModelToJson(_MedicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pet_id': instance.petId,
      'name': instance.name,
      'dosage': instance.dosage,
      'instructions': instance.instructions,
      'frequency_type': _$FrequencyTypeEnumMap[instance.frequencyType]!,
      'frequency_value': instance.frequencyValue,
      'schedule_times': instance.scheduleTimes,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'is_active': instance.isActive,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$FrequencyTypeEnumMap = {
  FrequencyType.daily: 'daily',
  FrequencyType.weekly: 'weekly',
  FrequencyType.interval_hours: 'interval_hours',
  FrequencyType.as_needed: 'as_needed',
};
