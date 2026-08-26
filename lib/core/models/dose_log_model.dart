import 'package:freezed_annotation/freezed_annotation.dart';

part 'dose_log_model.freezed.dart';
part 'dose_log_model.g.dart';

enum DoseStatus { pending, given, missed, skipped }

@freezed
abstract class DoseLogModel with _$DoseLogModel {
  const factory DoseLogModel({
    required String id,
    required String medicationId,
    required String petId,
    required DateTime scheduledTime,
    DateTime? givenAt,
    String? givenBy,
    @Default(DoseStatus.pending) DoseStatus status,
    String? photoUrl,
    String? notes,
    DateTime? createdAt,
  }) = _DoseLogModel;

  factory DoseLogModel.fromJson(Map<String, dynamic> json) =>
      _$DoseLogModelFromJson(json);
}
