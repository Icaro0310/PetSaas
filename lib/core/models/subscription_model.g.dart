// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) =>
    _SubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      status:
          $enumDecodeNullable(_$SubscriptionStatusEnumMap, json['status']) ??
          SubscriptionStatus.trialing,
      plan: json['plan'] as String? ?? 'premium',
      stripeCustomerId: json['stripe_customer_id'] as String?,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      currentPeriodStart: json['current_period_start'] == null
          ? null
          : DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: json['current_period_end'] == null
          ? null
          : DateTime.parse(json['current_period_end'] as String),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$SubscriptionModelToJson(_SubscriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'status': _$SubscriptionStatusEnumMap[instance.status]!,
      'plan': instance.plan,
      'stripe_customer_id': instance.stripeCustomerId,
      'stripe_subscription_id': instance.stripeSubscriptionId,
      'current_period_start': instance.currentPeriodStart?.toIso8601String(),
      'current_period_end': instance.currentPeriodEnd?.toIso8601String(),
      'created_at': instance.createdAt?.toIso8601String(),
    };

const _$SubscriptionStatusEnumMap = {
  SubscriptionStatus.active: 'active',
  SubscriptionStatus.cancelled: 'cancelled',
  SubscriptionStatus.past_due: 'past_due',
  SubscriptionStatus.trialing: 'trialing',
};
