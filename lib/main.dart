import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase - handle duplicate-app on hot restarts
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully.");
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Firebase already initialized (e.g. after hot restart on web)
      // This is fine - use the existing app instance
      debugPrint("Firebase already initialized, using existing instance.");
    } else {
      debugPrint("Firebase initialization error [${e.code}]: ${e.message}");
    }
  } catch (e) {
    debugPrint("Firebase initialization unexpected error: $e");
  }

  // Initialize Google Sign-In (native platforms only - web uses popup)
  if (!kIsWeb) {
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint("Google Sign-In initialization failed: $e");
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Smart Inventory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
