// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetModel _$PetModelFromJson(Map<String, dynamic> json) => _PetModel(
  id: json['id'] as String,
  ownerId: json['owner_id'] as String,
  name: json['name'] as String,
  species: $enumDecode(_$PetSpeciesEnumMap, json['species']),
  breed: json['breed'] as String?,
  birthDate: json['birth_date'] == null
      ? null
      : DateTime.parse(json['birth_date'] as String),
  weightKg: (json['weight_kg'] as num?)?.toDouble(),
  color: json['color'] as String?,
  photoUrl: json['photo_url'] as String?,
  description: json['description'] as String?,
  emergencyInfo: json['emergency_info'] as String?,
  allergies: json['allergies'] as String?,
  criticalMeds: json['critical_meds'] as String?,
  warnings: json['warnings'] as String?,
  microchipId: json['microchip_id'] as String?,
  vetName: json['vet_name'] as String?,
  vetPhone: json['vet_phone'] as String?,
  isLost: json['is_lost'] as bool? ?? false,
  lostAt: json['lost_at'] == null
      ? null
      : DateTime.parse(json['lost_at'] as String),
  qrCodeUuid: json['qr_code_uuid'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$PetModelToJson(_PetModel instance) => <String, dynamic>{
  'id': instance.id,
  'owner_id': instance.ownerId,
  'name': instance.name,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'breed': instance.breed,
  'birth_date': instance.birthDate?.toIso8601String(),
  'weight_kg': instance.weightKg,
  'color': instance.color,
  'photo_url': instance.photoUrl,
  'description': instance.description,
  'emergency_info': instance.emergencyInfo,
  'allergies': instance.allergies,
  'critical_meds': instance.criticalMeds,
  'warnings': instance.warnings,
  'microchip_id': instance.microchipId,
  'vet_name': instance.vetName,
  'vet_phone': instance.vetPhone,
  'is_lost': instance.isLost,
  'lost_at': instance.lostAt?.toIso8601String(),
  'qr_code_uuid': instance.qrCodeUuid,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};

const _$PetSpeciesEnumMap = {PetSpecies.dog: 'dog', PetSpecies.cat: 'cat'};
