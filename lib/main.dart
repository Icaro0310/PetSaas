import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';

import 'firebase_options.dart';

const _sentryDsn =
    'https://994d8d5c648219bc5ab06cdf891d8614@o4512017951948800.ingest.de.sentry.io/4512018103009360';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Sentry - inicializa antes do runApp para capturar erros nativos
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
    },
    appRunner: () async {
      // PostHog
      try {
        final config = PostHogConfig(
          'phc_yUpratCpKeH3Nqgd7bmKmBZBhXa5d7D4WVwXUBiiqQYx',
        );
        config.host = 'https://eu.i.posthog.com';
        await Posthog().setup(config);
      } catch (e) {
        debugPrint('PostHog init skipped: $e');
      }

      // Supabase
      await SupabaseService.initialize();

      // Firebase (Android usa google-services.json; Web usa firebase_options.dart)
      var firebaseInitialized = false;
      try {
        await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform);
        firebaseInitialized = true;
      } catch (e) {
        debugPrint('Firebase init skipped: $e');
      }

      // Crashlytics (apenas se Firebase inicializou corretamente)
      if (firebaseInitialized) {
        try {
          // Garante que PII (dados pessoais) NAO sao enviados ao Crashlytics
          await FirebaseCrashlytics.instance
              .setCrashlyticsCollectionEnabled(!kDebugMode);
          FlutterError.onError =
              FirebaseCrashlytics.instance.recordFlutterFatalError;
          PlatformDispatcher.instance.onError = (error, stack) {
            try {
              FirebaseCrashlytics.instance
                  .recordError(error, stack, fatal: true);
            } catch (_) {}
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

      // URLs limpas na Web para /p/<uuid> funcionar em hosts estaticos
      usePathUrlStrategy();
    },
  );

  runApp(
    DefaultAssetBundle(
      bundle: SentryAssetBundle(),
      child: const ProviderScope(child: PetCareApp()),
    ),
  );
}
