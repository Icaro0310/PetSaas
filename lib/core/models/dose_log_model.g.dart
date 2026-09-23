// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoseLogModel _$DoseLogModelFromJson(Map<String, dynamic> json) =>
    _DoseLogModel(
      id: json['id'] as String,
      medicationId: json['medication_id'] as String,
      petId: json['pet_id'] as String,
      scheduledTime: DateTime.parse(json['scheduled_time'] as String),
      givenAt: json['given_at'] == null
          ? null
          : DateTime.parse(json['given_at'] as String),
      givenBy: json['given_by'] as String?,
      status:
          $enumDecodeNullable(_$DoseStatusEnumMap, json['status']) ??
          DoseStatus.pending,
      photoUrl: json['photo_url'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$DoseLogModelToJson(_DoseLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medication_id': instance.medicationId,
      'pet_id': instance.petId,
      'scheduled_time': instance.scheduledTime.toIso8601String(),
      'given_at': instance.givenAt?.toIso8601String(),
      'given_by': instance.givenBy,
      'status': _$DoseStatusEnumMap[instance.status]!,
      'photo_url': instance.photoUrl,
      'notes': instance.notes,
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$DoseStatusEnumMap = {
  DoseStatus.pending: 'pending',
  DoseStatus.given: 'given',
  DoseStatus.missed: 'missed',
  DoseStatus.skipped: 'skipped',
};
