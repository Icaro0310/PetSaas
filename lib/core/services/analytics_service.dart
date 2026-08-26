import 'package:firebase_analytics/firebase_analytics.dart';

/// Servico de analytics (Firebase). Loga eventos-chave do produto.
class AnalyticsService {
  AnalyticsService._();

  static FirebaseAnalytics? _analytics;

  static FirebaseAnalytics? get instance {
    _analytics ??= FirebaseAnalytics.instance;
    return _analytics;
  }

  static Future<void> log(String name, {Map<String, dynamic>? params}) async {
    try {
      await instance?.logEvent(
        name: name,
        parameters: params?.map((k, v) => MapEntry(k, v.toString())),
      );
    } catch (_) {
      // Analytics e best-effort; nao quebra fluxo.
    }
  }

  // Eventos do produto
  static Future<void> petCreated() => log('pet_created');
  static Future<void> medicationCreated() => log('medication_created');
  static Future<void> doseMarkedGiven() => log('dose_marked_given');
  static Future<void> qrScanned() => log('qr_scanned');
  static Future<void> petFoundMessageSent() => log('pet_found_message_sent');
  static Future<void> caregiverInvited() => log('caregiver_invited');
  static Future<void> subscriptionStarted() => log('subscription_started');
}
