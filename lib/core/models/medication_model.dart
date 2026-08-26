import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_model.freezed.dart';
part 'medication_model.g.dart';

enum FrequencyType {
  daily,
  weekly,
  interval_hours,
  as_needed,
}

@freezed
abstract class MedicationModel with _$MedicationModel {
  const factory MedicationModel({
    required String id,
    required String petId,
    required String name,
    required String dosage,
    String? instructions,
    required FrequencyType frequencyType,
    int? frequencyValue,
    @Default([]) List<String> scheduleTimes,
    required DateTime startDate,
    DateTime? endDate,
    @Default(true) bool isActive,
    DateTime? createdAt,
  }) = _MedicationModel;

  factory MedicationModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationModelFromJson(json);
}
