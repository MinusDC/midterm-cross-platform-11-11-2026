import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/firebase_config.dart';
import 'providers/product_provider.dart';
import 'screens/home_screen.dart';
import 'services/cloudinary_service.dart';
import 'services/firebase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    runApp(
      StartupErrorApp(
        message:
            'Không thể đọc file .env: $error. '
            'Hãy tạo file từ .env.example và chạy lại ứng dụng.',
      ),
    );
    return;
  }

  if (!FirebaseConfig.isConfigured) {
    runApp(const SetupApp());
    return;
  }

  try {
    await Firebase.initializeApp(options: FirebaseConfig.options);
  } catch (error) {
    runApp(StartupErrorApp(message: error.toString()));
    return;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ProductProvider(
        firebaseService: FirebaseService(),
        cloudinaryService: CloudinaryService.fromDotEnv(),
      ),
      child: const ProductApp(),
    ),
  );
}

class ProductApp extends StatelessWidget {
  const ProductApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF226B55);
    return MaterialApp(
      title: 'Quản lý sản phẩm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          surface: const Color(0xFFF7F8F5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F5),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE5EAE5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: seedColor, width: 1.5),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class SetupApp extends StatelessWidget {
  const SetupApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _MessageScreen(
      title: 'Cần cấu hình Firebase',
      message:
          'Điền FIREBASE_API_KEY, FIREBASE_APP_ID, '
          'FIREBASE_MESSAGING_SENDER_ID và FIREBASE_PROJECT_ID trong file .env. '
          'Xem README.md để biết cách lấy giá trị và cấu hình Cloudinary.',
    ),
  );
}

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: _MessageScreen(
      title: 'Không thể khởi động Firebase',
      message: message,
    ),
  );
}

class _MessageScreen extends StatelessWidget {
  const _MessageScreen({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.settings_suggest_outlined, size: 48),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              SelectableText(message, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    ),
  );
}
