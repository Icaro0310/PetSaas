import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../services/supabase_service.dart';

/// Regista o token FCM do dispositivo no Supabase (tabela user_devices)
/// para que as edge functions possam enviar push.
class FcmService {
  FcmService._();

  static Future<void> initialize() async {
    if (kIsWeb) return; // FCM web requer config separada

    try {
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus !=
              AuthorizationStatus.provisional) {
        return;
      }

      final token = await messaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }

      // Atualiza quando o token renovar
      messaging.onTokenRefresh.listen(_registerToken);

      // Background handler
      FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    } catch (e) {
      debugPrint('FCM init skipped: $e');
    }
  }

  static Future<void> _registerToken(String token) async {
    final user = SupabaseService.currentUserId;
    if (user == null) return;
    try {
      await SupabaseService.client.from('user_devices').upsert({
        'user_id': user,
        'fcm_token': token,
        'platform': defaultTargetPlatform.name,
      });
    } catch (e) {
      debugPrint('FCM register failed: $e');
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    // Apenas log; tratamento de UI em foreground.
    debugPrint('FCM background: ${message.notification?.title}');
  }
}
