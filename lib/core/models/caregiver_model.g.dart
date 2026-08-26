// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caregiver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaregiverModel _$CaregiverModelFromJson(Map<String, dynamic> json) =>
    _CaregiverModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      caregiverId: json['caregiverId'] as String?,
      caregiverEmail: json['caregiverEmail'] as String,
      inviteToken: json['inviteToken'] as String?,
      status:
          $enumDecodeNullable(_$CaregiverStatusEnumMap, json['status']) ??
          CaregiverStatus.pending,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['view', 'mark_dose'],
      invitedAt: json['invitedAt'] == null
          ? null
          : DateTime.parse(json['invitedAt'] as String),
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      removedAt: json['removedAt'] == null
          ? null
          : DateTime.parse(json['removedAt'] as String),
    );

Map<String, dynamic> _$CaregiverModelToJson(_CaregiverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'petId': instance.petId,
      'ownerId': instance.ownerId,
      'caregiverId': instance.caregiverId,
      'caregiverEmail': instance.caregiverEmail,
      'inviteToken': instance.inviteToken,
      'status': _$CaregiverStatusEnumMap[instance.status]!,
      'permissions': instance.permissions,
      'invitedAt': instance.invitedAt?.toIso8601String(),
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'removedAt': instance.removedAt?.toIso8601String(),
    };

const _$CaregiverStatusEnumMap = {
  CaregiverStatus.pending: 'pending',
  CaregiverStatus.active: 'active',
  CaregiverStatus.removed: 'removed',
};
