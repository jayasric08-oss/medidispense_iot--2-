import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/dashboard/dashboard_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: CyberMedicalTheme.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('================================');
    debugPrint('FIREBASE INITIALIZED SUCCESSFULLY');
    debugPrint('================================');
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  runApp(const MediDispenseApp());
}

class MediDispenseApp extends StatelessWidget {
  const MediDispenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediDispense IoT',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: CyberMedicalTheme.darkTheme,
      home: const DashboardScreen(),
    );
  }
}