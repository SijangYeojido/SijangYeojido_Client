import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'theme/app_theme.dart';
import 'providers/app_data_provider.dart';
import 'providers/auth_provider.dart';
import 'services/notification_service.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/onboarding/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR');
  await NotificationService.instance.initialize();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final authProvider = AuthProvider();
  if (AppConfig.resetLocalDataOnLaunch) {
    await authProvider.resetLocalDataForFreshRun();
  }
  await authProvider.restoreSession();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: NotificationService.instance),
        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],
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
        if (!auth.hasRestoredSession) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (auth.isLoggedIn && auth.needsProfileSetup) {
          return const ProfileSetupScreen();
        }
        return const MainScaffold();
      },
    );
  }
}
