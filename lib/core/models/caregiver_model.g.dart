// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'caregiver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaregiverModel _$CaregiverModelFromJson(Map<String, dynamic> json) =>
    _CaregiverModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      ownerId: json['owner_id'] as String,
      caregiverId: json['caregiver_id'] as String?,
      caregiverEmail: json['caregiver_email'] as String,
      inviteToken: json['invite_token'] as String?,
      status:
          $enumDecodeNullable(_$CaregiverStatusEnumMap, json['status']) ??
          CaregiverStatus.pending,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const ['view', 'mark_dose'],
      invitedAt: json['invited_at'] == null
          ? null
          : DateTime.parse(json['invited_at'] as String),
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      removedAt: json['removed_at'] == null
          ? null
          : DateTime.parse(json['removed_at'] as String),
    );

Map<String, dynamic> _$CaregiverModelToJson(_CaregiverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pet_id': instance.petId,
      'owner_id': instance.ownerId,
      'caregiver_id': instance.caregiverId,
      'caregiver_email': instance.caregiverEmail,
      'invite_token': instance.inviteToken,
      'status': _$CaregiverStatusEnumMap[instance.status]!,
      'permissions': instance.permissions,
      'invited_at': instance.invitedAt?.toIso8601String(),
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'removed_at': instance.removedAt?.toIso8601String(),
    };

const _$CaregiverStatusEnumMap = {
  CaregiverStatus.pending: 'pending',
  CaregiverStatus.active: 'active',
  CaregiverStatus.removed: 'removed',
};
