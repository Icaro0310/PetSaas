// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PetModel _$PetModelFromJson(Map<String, dynamic> json) => _PetModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  species: $enumDecode(_$PetSpeciesEnumMap, json['species']),
  breed: json['breed'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  color: json['color'] as String?,
  photoUrl: json['photoUrl'] as String?,
  description: json['description'] as String?,
  emergencyInfo: json['emergencyInfo'] as String?,
  allergies: json['allergies'] as String?,
  criticalMeds: json['criticalMeds'] as String?,
  warnings: json['warnings'] as String?,
  microchipId: json['microchipId'] as String?,
  vetName: json['vetName'] as String?,
  vetPhone: json['vetPhone'] as String?,
  isLost: json['isLost'] as bool? ?? false,
  lostAt: json['lostAt'] == null
      ? null
      : DateTime.parse(json['lostAt'] as String),
  qrCodeUuid: json['qrCodeUuid'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PetModelToJson(_PetModel instance) => <String, dynamic>{
  'id': instance.id,
  'ownerId': instance.ownerId,
  'name': instance.name,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'breed': instance.breed,
  'birthDate': instance.birthDate?.toIso8601String(),
  'weightKg': instance.weightKg,
  'color': instance.color,
  'photoUrl': instance.photoUrl,
  'description': instance.description,
  'emergencyInfo': instance.emergencyInfo,
  'allergies': instance.allergies,
  'criticalMeds': instance.criticalMeds,
  'warnings': instance.warnings,
  'microchipId': instance.microchipId,
  'vetName': instance.vetName,
  'vetPhone': instance.vetPhone,
  'isLost': instance.isLost,
  'lostAt': instance.lostAt?.toIso8601String(),
  'qrCodeUuid': instance.qrCodeUuid,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$PetSpeciesEnumMap = {PetSpecies.dog: 'dog', PetSpecies.cat: 'cat'};
