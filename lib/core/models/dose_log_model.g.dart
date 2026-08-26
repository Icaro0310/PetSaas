// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dose_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoseLogModel _$DoseLogModelFromJson(Map<String, dynamic> json) =>
    _DoseLogModel(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      petId: json['petId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      givenAt: json['givenAt'] == null
          ? null
          : DateTime.parse(json['givenAt'] as String),
      givenBy: json['givenBy'] as String?,
      status:
          $enumDecodeNullable(_$DoseStatusEnumMap, json['status']) ??
          DoseStatus.pending,
      photoUrl: json['photoUrl'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DoseLogModelToJson(_DoseLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicationId': instance.medicationId,
      'petId': instance.petId,
      'scheduledTime': instance.scheduledTime.toIso8601String(),
      'givenAt': instance.givenAt?.toIso8601String(),
      'givenBy': instance.givenBy,
      'status': _$DoseStatusEnumMap[instance.status]!,
      'photoUrl': instance.photoUrl,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

const _$DoseStatusEnumMap = {
  DoseStatus.pending: 'pending',
  DoseStatus.given: 'given',
  DoseStatus.missed: 'missed',
  DoseStatus.skipped: 'skipped',
};
