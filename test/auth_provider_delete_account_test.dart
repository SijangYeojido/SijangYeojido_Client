import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sijangyeojido_client/providers/auth_provider.dart';
import 'package:sijangyeojido_client/services/api_client.dart';
import 'package:sijangyeojido_client/services/auth_api.dart' as backend_auth;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  late Map<String, String> secureStorage;

  setUp(() {
    secureStorage = <String, String>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final args = Map<String, Object?>.from(call.arguments as Map);
          final key = args['key'] as String?;
          switch (call.method) {
            case 'read':
              return secureStorage[key];
            case 'write':
              secureStorage[key!] = args['value'] as String;
              return null;
            case 'delete':
              secureStorage.remove(key);
              return null;
            case 'deleteAll':
              secureStorage.clear();
              return null;
            case 'containsKey':
              return secureStorage.containsKey(key);
            case 'readAll':
              return secureStorage;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'deleteAccount completes locally when backend delete endpoint is missing',
    () async {
      final auth = AuthProvider(authApi: _MissingDeleteAuthApi());

      final loggedIn = await auth.loginWithEmail(
        email: 'review-user@sijangyeojido.com',
        password: 'SijangReview2026!',
      );
      expect(loggedIn, isTrue);
      expect(auth.isLoggedIn, isTrue);

      final deleted = await auth.deleteAccount();
      expect(deleted, isTrue);
      expect(auth.isLoggedIn, isFalse);

      final loginAgain = await auth.loginWithEmail(
        email: 'review-user@sijangyeojido.com',
        password: 'SijangReview2026!',
      );
      expect(loginAgain, isFalse);
      expect(auth.errorMessage, contains('삭제된 계정'));
    },
  );
}

class _MissingDeleteAuthApi extends backend_auth.AuthApi {
  @override
  Future<backend_auth.AuthSession> emailLogin({
    required String email,
    required String password,
  }) async {
    return backend_auth.AuthSession(
      accessToken: 'test-token',
      userId: 1,
      name: '심사 사용자',
      role: UserRole.customer,
    );
  }

  @override
  Future<void> deleteAccount() async {
    throw const ApiException(404, 'Cannot DELETE /users/me');
  }
}
