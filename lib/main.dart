import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  await SupabaseService.initialize();

  // Firebase (Android usa google-services.json; Web usa firebase_options.dart)
  var firebaseInitialized = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseInitialized = true;
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  // Crashlytics (apenas se Firebase inicializou corretamente)
  if (firebaseInitialized) {
    try {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        try {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        } catch (_) {
          // Crashlytics indisponivel; evita loop
        }
        return true;
      };
    } catch (_) {}
  }

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
