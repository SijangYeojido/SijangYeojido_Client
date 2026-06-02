import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_client.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService extends ChangeNotifier {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  bool _initialized = false;
  bool _firebaseAvailable = false;
  bool _permissionGranted = false;
  String? _token;
  Map<String, dynamic>? _preferences;

  bool get initialized => _initialized;
  bool get firebaseAvailable => _firebaseAvailable;
  bool get permissionGranted => _permissionGranted;
  String? get token => _token;
  Map<String, dynamic>? get preferences => _preferences;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
      _firebaseAvailable = true;
    } catch (_) {
      _firebaseAvailable = false;
    }
    notifyListeners();
  }

  Future<void> syncAfterLogin() async {
    await initialize();
    await loadPreferences();
    if (!_firebaseAvailable) return;

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    _permissionGranted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!_permissionGranted) {
      notifyListeners();
      return;
    }

    final token = await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      await _registerToken(token);
    }
    notifyListeners();
  }

  Future<void> deactivateCurrentToken() async {
    final currentToken = _token;
    if (currentToken == null || currentToken.isEmpty) return;
    try {
      await ApiClient.instance.delete(
        '/notifications/device-tokens/$currentToken',
      );
    } catch (_) {}
    _token = null;
    notifyListeners();
  }

  Future<void> loadPreferences() async {
    try {
      _preferences =
          await ApiClient.instance.get('/notifications/preferences')
              as Map<String, dynamic>;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> updatePreferences(Map<String, dynamic> body) async {
    _preferences =
        await ApiClient.instance.patch('/notifications/preferences', body: body)
            as Map<String, dynamic>;
    notifyListeners();
  }

  Future<void> _registerToken(String token) async {
    _token = token;
    try {
      await ApiClient.instance.post(
        '/notifications/device-tokens',
        body: {'token': token, 'platform': _platform, 'appVersion': '1.0.0'},
      );
    } catch (_) {}
    notifyListeners();
  }

  String get _platform {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }
}
