import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/app_routes.dart';
import 'core/app_theme.dart';
import 'viewmodels/home_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ); 
  } catch (e) {
    debugPrint('Firebase init failed. Did you run flutterfire configure?');
  }
  runApp(const CineBookApp());
}

class CineBookApp extends StatelessWidget {
  const CineBookApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
      ],
      child: MaterialApp.router(
        title: 'CineBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
