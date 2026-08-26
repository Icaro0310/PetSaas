import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await SupabaseService.initialize();

  // Firebase (defensivo: web precisa de config separada; Android usa google-services.json)
  try {
    if (kIsWeb) {
      // Web: requer firebaseOptions reais (flutterfire configure). Pula se ausente.
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBlsoSL-rmuepF2GFcMFpp5_bErc1Z3M4A',
          authDomain: 'saaspet-3386c.firebaseapp.com',
          projectId: 'saaspet-3386c',
          storageBucket: 'saaspet-3386c.firebasestorage.app',
          messagingSenderId: '401594264567',
          appId: '1:401594264567:web:0000000000000000000000',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  // Crashlytics (apenas se Firebase inicializou)
  try {
    FlutterError.onError =
        FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {}

  // Notificacoes locais + timezone
  await NotificationService.initialize();

  // FCM (push remoto) - registra token no Supabase
  try {
    await FcmService.initialize();
  } catch (e) {
    debugPrint('FCM skipped: $e');
  }

  runApp(const ProviderScope(child: PetCareApp()));
}
