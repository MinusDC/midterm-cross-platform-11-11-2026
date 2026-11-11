import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class FirebaseConfig {
  static String get apiKey => dotenv.env['FIREBASE_API_KEY']?.trim() ?? '';
  static String get appId => dotenv.env['FIREBASE_APP_ID']?.trim() ?? '';
  static String get messagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID']?.trim() ?? '';
  static String get projectId =>
      dotenv.env['FIREBASE_PROJECT_ID']?.trim() ?? '';

  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      messagingSenderId.isNotEmpty &&
      projectId.isNotEmpty;

  static FirebaseOptions get options => FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
  );
}
