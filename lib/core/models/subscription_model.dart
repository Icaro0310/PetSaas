import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

enum SubscriptionStatus { active, cancelled, past_due, trialing }

@freezed
abstract class SubscriptionModel with _$SubscriptionModel {
  const SubscriptionModel._();

  const factory SubscriptionModel({
    required String id,
    required String userId,
    @Default(SubscriptionStatus.trialing) SubscriptionStatus status,
    @Default('premium') String plan,
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);

  /// Indica se o usuário tem acesso premium (trial ativo ou assinatura ativa).
  bool get hasPremiumAccess {
    if (status == SubscriptionStatus.active) return true;
    if (status == SubscriptionStatus.trialing) {
      final end = currentPeriodEnd;
      return end == null || end.isAfter(DateTime.now());
    }
    return false;
  }
}
