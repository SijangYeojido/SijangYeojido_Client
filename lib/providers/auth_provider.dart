import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_config.dart';
import '../config/review_accounts.dart';
import '../models/auth_role.dart';
import '../services/api_client.dart';
import '../services/auth_api.dart' as backend_auth;
import '../services/favorite_service.dart';
import '../services/notification_service.dart';

export '../models/auth_role.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({backend_auth.AuthApi? authApi})
    : _authApi = authApi ?? backend_auth.AuthApi();

  static const _tokenKey = 'sijang.accessToken';
  static const _localEmailKey = 'sijang.localEmail';
  static const _localPasswordKey = 'sijang.localPassword';
  static const _localNameKey = 'sijang.localName';
  static const _localRoleKey = 'sijang.localRole';

  final backend_auth.AuthApi _authApi;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _hasRestoredSession = false;
  UserRole _role = UserRole.customer;
  String? _userName;
  String? _profileImage;
  String? _accessToken;
  String? _errorMessage;
  String? _sessionRestoreMessage;
  bool _needsProfileSetup = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get hasRestoredSession => _hasRestoredSession;
  UserRole get role => _role;
  String? get userName => _userName;
  String? get profileImage => _profileImage;
  String? get accessToken => _accessToken;
  String? get errorMessage => _errorMessage;
  String? get sessionRestoreMessage => _sessionRestoreMessage;
  bool get needsProfileSetup => _needsProfileSetup;

  Future<void> resetLocalDataForFreshRun() async {
    await _storage.delete(key: _tokenKey);
    ApiClient.instance.accessToken = null;
    FavoriteService().favoriteIds.clear();
    _clearSession();
  }

  Future<void> restoreSession() async {
    _sessionRestoreMessage = null;
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) {
      _hasRestoredSession = true;
      notifyListeners();
      return;
    }

    ApiClient.instance.accessToken = token;
    try {
      final profile = await _authApi.me();
      _applyProfile(
        token: token,
        name: profile.name,
        role: profile.role,
        profileImage: profile.profileImage,
        needsProfileSetup: profile.needsProfileSetup,
      );
      await FavoriteService().loadFavorites();
      await NotificationService.instance.syncAfterLogin();
    } catch (error) {
      await _storage.delete(key: _tokenKey);
      ApiClient.instance.accessToken = null;
      _clearSession();
      _sessionRestoreMessage = _sessionRestoreError(error);
    } finally {
      _hasRestoredSession = true;
      notifyListeners();
    }
  }

  Future<bool> loginWithReviewAccount(UserRole role) async {
    final account = ReviewAccounts.forRole(role);
    return _runLogin(() async {
      try {
        return await _authApi.emailLogin(
          email: account.email,
          password: account.password,
        );
      } catch (_) {
        return _createLocalEmailSession(
          name: account.label,
          email: account.email,
          password: account.password,
          role: account.role,
        );
      }
    });
  }

  void clearSessionRestoreMessage() {
    _sessionRestoreMessage = null;
    notifyListeners();
  }

  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _runLogin(() async {
      try {
        return await _authApi.emailLogin(
          email: email.trim(),
          password: password,
        );
      } catch (error) {
        final fallback = await _tryLocalEmailLogin(email, password);
        if (fallback != null) return fallback;
        rethrow;
      }
    });
  }

  Future<bool> registerWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    return _runLogin(() async {
      try {
        return await _authApi.emailRegister(
          name: name.trim(),
          email: email.trim(),
          password: password,
          role: role,
        );
      } catch (error) {
        if (!_canUseLocalAuthFallback(error)) rethrow;
        return _createLocalEmailSession(
          name: name.trim(),
          email: email.trim(),
          password: password,
          role: role,
        );
      }
    });
  }

  Future<bool> _runLogin(
    Future<backend_auth.AuthSession> Function() action,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await action();
      if (session.accessToken.isEmpty) {
        throw const ApiException(401, '로그인 응답에 토큰이 없습니다.');
      }
      await _storage.write(key: _tokenKey, value: session.accessToken);
      _applyProfile(
        token: session.accessToken,
        name: session.name,
        role: session.role,
        profileImage: session.profileImage,
        needsProfileSetup: session.needsProfileSetup,
      );
      await FavoriteService().loadFavorites();
      await NotificationService.instance.syncAfterLogin();
      return true;
    } catch (error) {
      _setError(_friendlyError(error));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await NotificationService.instance.deactivateCurrentToken();
    await _storage.delete(key: _tokenKey);
    ApiClient.instance.accessToken = null;
    _clearSession();
    notifyListeners();
  }

  void login(String email, String password, UserRole role) {
    _isLoggedIn = true;
    _hasRestoredSession = true;
    _role = role;
    _userName = role == UserRole.merchant ? '사장님' : '사용자';
    _needsProfileSetup = false;
    _errorMessage = null;
    notifyListeners();
  }

  bool _canUseLocalAuthFallback(Object error) {
    if (!AppConfig.useLocalAuthFallback) return false;
    return error is! ApiException || error.statusCode == 0;
  }

  Future<backend_auth.AuthSession?> _tryLocalEmailLogin(
    String email,
    String password,
  ) async {
    final savedEmail = await _storage.read(key: _localEmailKey);
    final savedPassword = await _storage.read(key: _localPasswordKey);
    if (savedEmail != email.trim().toLowerCase() || savedPassword != password) {
      return null;
    }

    final role = roleFromServer(await _storage.read(key: _localRoleKey));
    return backend_auth.AuthSession(
      accessToken: _localJwt(email: email, role: role),
      userId: 0,
      name: await _storage.read(key: _localNameKey) ?? '사용자',
      role: role,
    );
  }

  Future<backend_auth.AuthSession> _createLocalEmailSession({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    await _storage.write(key: _localEmailKey, value: email.toLowerCase());
    await _storage.write(key: _localPasswordKey, value: password);
    await _storage.write(key: _localNameKey, value: name);
    await _storage.write(key: _localRoleKey, value: role.toServerRole());
    return backend_auth.AuthSession(
      accessToken: _localJwt(email: email, role: role),
      userId: 0,
      name: name,
      role: role,
    );
  }

  String _localJwt({required String email, required UserRole role}) {
    String encodeJson(Map<String, Object?> value) =>
        base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
    final issuedAt = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return [
      encodeJson({'alg': 'none', 'typ': 'JWT'}),
      encodeJson({
        'sub': email.toLowerCase(),
        'role': role.toServerRole(),
        'iat': issuedAt,
        'aud': 'sijangyeojido-local',
      }),
      'local',
    ].join('.');
  }

  void signup(String email, String password, String name, UserRole role) {
    _isLoggedIn = true;
    _hasRestoredSession = true;
    _role = role;
    _userName = name;
    _needsProfileSetup = false;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleRole() {
    _role = _role == UserRole.customer ? UserRole.merchant : UserRole.customer;
    notifyListeners();
  }

  void _applyProfile({
    required String token,
    required String name,
    required UserRole role,
    String? profileImage,
    bool needsProfileSetup = false,
  }) {
    _accessToken = token;
    ApiClient.instance.accessToken = token;
    _isLoggedIn = true;
    _role = role;
    _userName = name;
    _profileImage = profileImage;
    _needsProfileSetup = needsProfileSetup;
    _errorMessage = null;
  }

  Future<bool> completeProfile({required String name}) async {
    final trimmed = name.trim();
    if (trimmed.length < 2) {
      _setError('닉네임은 2자 이상 입력해 주세요.');
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authApi.updateProfile(name: trimmed);
      _userName = profile.name;
      _profileImage = profile.profileImage;
      _needsProfileSetup = false;
      return true;
    } catch (error) {
      _setError(_friendlyError(error));
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _clearSession() {
    _isLoggedIn = false;
    _role = UserRole.customer;
    _userName = null;
    _profileImage = null;
    _accessToken = null;
    _needsProfileSetup = false;
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is ApiException) return error.message;
    final message = error.toString();
    if (message.contains('cancel')) return '로그인이 취소되었습니다.';
    if (message.contains('network') || message.contains('SocketException')) {
      return '네트워크 연결을 확인해 주세요.';
    }
    return '로그인에 실패했습니다. 서버 상태를 확인해 주세요.';
  }

  String _sessionRestoreError(Object error) {
    if (error is ApiException) {
      if (error.statusCode == 401 || error.statusCode == 403) {
        return '로그인 세션이 만료되어 다시 로그인해 주세요.';
      }
      if (error.statusCode == 0) {
        return '서버에 연결할 수 없어 로그인 화면으로 이동했어요. 네트워크를 확인해 주세요.';
      }
      return error.message;
    }
    final message = error.toString();
    if (message.contains('network') || message.contains('SocketException')) {
      return '서버에 연결할 수 없어 로그인 화면으로 이동했어요. 네트워크를 확인해 주세요.';
    }
    return '로그인 세션이 만료되어 다시 로그인해 주세요.';
  }
}
