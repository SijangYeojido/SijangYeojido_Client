import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: const SijangYeojidoApp(),
    ),
  );
}

class SijangYeojidoApp extends StatefulWidget {
  const SijangYeojidoApp({super.key});

  @override
  State<SijangYeojidoApp> createState() => _SijangYeojidoAppState();
}

class _SijangYeojidoAppState extends State<SijangYeojidoApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시장여지도',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _showSplash
          ? SplashScreen(onComplete: () => setState(() => _showSplash = false))
          : const _AuthWrapper(),
    );
  }
}

class _AuthWrapper extends StatelessWidget {
  const _AuthWrapper();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return auth.isLoggedIn ? const MainScaffold() : const LoginScreen();
      },
    );
  }
}
