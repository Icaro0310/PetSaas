import 'package:freezed_annotation/freezed_annotation.dart';

part 'caregiver_model.freezed.dart';
part 'caregiver_model.g.dart';

enum CaregiverStatus { pending, active, removed }

@freezed
abstract class CaregiverModel with _$CaregiverModel {
  const factory CaregiverModel({
    required String id,
    required String petId,
    required String ownerId,
    String? caregiverId,
    required String caregiverEmail,
    String? inviteToken,
    @Default(CaregiverStatus.pending) CaregiverStatus status,
    @Default(['view', 'mark_dose']) List<String> permissions,
    DateTime? invitedAt,
    DateTime? acceptedAt,
    DateTime? removedAt,
  }) = _CaregiverModel;

  factory CaregiverModel.fromJson(Map<String, dynamic> json) =>
      _$CaregiverModelFromJson(json);
}
