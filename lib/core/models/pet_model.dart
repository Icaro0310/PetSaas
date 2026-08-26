import 'package:freezed_annotation/freezed_annotation.dart';

part 'pet_model.freezed.dart';
part 'pet_model.g.dart';

enum PetSpecies { dog, cat }

@freezed
abstract class PetModel with _$PetModel {
  const factory PetModel({
    required String id,
    required String ownerId,
    required String name,
    required PetSpecies species,
    String? breed,
    DateTime? birthDate,
    double? weightKg,
    String? color,
    String? photoUrl,
    String? description,
    String? emergencyInfo,
    String? allergies,
    String? criticalMeds,
    String? warnings,
    String? microchipId,
    String? vetName,
    String? vetPhone,
    @Default(false) bool isLost,
    DateTime? lostAt,
    String? qrCodeUuid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _PetModel;

  factory PetModel.fromJson(Map<String, dynamic> json) =>
      _$PetModelFromJson(json);
}
