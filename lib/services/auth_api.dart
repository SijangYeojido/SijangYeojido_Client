import '../models/auth_role.dart';
import 'api_client.dart';

class AuthSession {
  final String accessToken;
  final int userId;
  final String name;
  final UserRole role;
  final String? profileImage;
  final bool needsProfileSetup;

  const AuthSession({
    required this.accessToken,
    required this.userId,
    required this.name,
    required this.role,
    this.profileImage,
    this.needsProfileSetup = false,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return AuthSession(
      accessToken:
          json['accessToken']?.toString() ??
          json['access_token']?.toString() ??
          '',
      userId: int.tryParse(user['id']?.toString() ?? '') ?? 0,
      name: user['name']?.toString() ?? '사용자',
      role: roleFromServer(user['role']?.toString()),
      profileImage: user['profileImage']?.toString(),
      needsProfileSetup: user['needsProfileSetup'] == true,
    );
  }
}

class AuthProfile {
  final int id;
  final String name;
  final UserRole role;
  final String? profileImage;
  final bool needsProfileSetup;

  const AuthProfile({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    this.needsProfileSetup = false,
  });

  factory AuthProfile.fromJson(Map<String, dynamic> json) {
    return AuthProfile(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '사용자',
      role: roleFromServer(json['role']?.toString()),
      profileImage: json['profileImage']?.toString(),
      needsProfileSetup: _defaultNames.contains(json['name']?.toString()),
    );
  }
}

const _defaultNames = {'카카오 사용자', 'Google 사용자', '네이버 사용자', '사용자', '시장여지도 사용자'};

class AuthApi {
  AuthApi({ApiClient? client}) : _client = client ?? ApiClient.instance;

  final ApiClient _client;

  Future<AuthSession> emailLogin({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      '/auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthSession.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthSession> emailRegister({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final response = await _client.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'role': role.toServerRole(),
      },
    );
    return AuthSession.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthProfile> me() async {
    final response = await _client.get('/users/me');
    return AuthProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthProfile> updateProfile({
    required String name,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{'name': name};
    if (profileImage case final image?) {
      body['profileImage'] = image;
    }

    final response = await _client.patch('/users/me', body: body);
    return AuthProfile.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteAccount() async {
    await _client.delete('/users/me');
  }
}
