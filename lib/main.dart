import 'package:doctors_web/routes/routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDz1cOWwRN38SW32aRkNNHKVpgNBTUNbJs",
        authDomain: "health-mob-38843.firebaseapp.com",
        projectId: "health-mob-38843",
        storageBucket: "health-mob-38843.firebasestorage.app",
        messagingSenderId: "429589279697",
        appId: "1:429589279697:web:0cd37656c8c570e6fe26f0"
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Doctors Web App',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
    );
  }
}
