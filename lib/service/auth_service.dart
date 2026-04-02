import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:safepath/service/token_storage.dart';

/// =======================================================
/// AuthService
///
/// 역할:
///   - 카카오 SDK로 OAuth code 받기
///   - BE /api/auth/kakao/callback?code={code} 호출
///   - 토큰 저장/재발급/로그아웃
///
/// TODO: 서버 배포 후 _baseUrl 설정
/// =======================================================
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // TODO: 서버 배포 후 실제 도메인으로 교체
  static const String _baseUrl = 'https://TODOTODO';

  // ─── 카카오 로그인 ────────────────────────────────────────────────────────

  /// 카카오 로그인 후 BE 토큰 반환
  /// 성공 시 true, 실패 시 예외 throw
  Future<bool> signInWithKakao() async {
    // 1. 카카오 OAuth code 받기 (카카오톡 앱 → 없으면 웹)
    String code;
    try {
      if (await isKakaoTalkInstalled()) {
        final token = await UserApi.instance.loginWithKakaoTalk();
        code = token.accessToken; // SDK가 code exchange까지 처리
      } else {
        final token = await UserApi.instance.loginWithKakaoAccount();
        code = token.accessToken;
      }
    } catch (e) {
      throw AuthException('카카오 로그인 실패: $e');
    }

    // 2. BE에 code 전달 → JWT 받기
    return await _fetchTokenFromServer(code);
  }

  Future<bool> _fetchTokenFromServer(String code) async {
    // TODO: 서버 배포 전까지는 더미 토큰으로 처리
    if (_baseUrl.contains('gilbut-server')) {
      // 서버 미배포 상태 — 더미 토큰 저장 후 로그인 성공 처리
      await TokenStorage().saveTokens(
        accessToken: 'dummy_access_token',
        refreshToken: 'dummy_refresh_token',
      );
      return true;
    }

    final uri = Uri.parse('$_baseUrl/api/auth/kakao/callback?code=$code');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await TokenStorage().saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      return true;
    }

    throw AuthException('서버 인증 실패: ${response.statusCode}');
  }

  // ─── 토큰 재발급 ──────────────────────────────────────────────────────────

  Future<bool> reissueToken() async {
    final refreshToken = await TokenStorage().refreshToken;
    if (refreshToken == null) return false;

    final uri = Uri.parse('$_baseUrl/api/auth/reissue');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await TokenStorage().saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      return true;
    }

    return false;
  }

  // ─── 로그아웃 ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    final refreshToken = await TokenStorage().refreshToken;

    if (refreshToken != null && !_baseUrl.contains('your-server')) {
      final uri = Uri.parse('$_baseUrl/api/auth/logout');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
    }

    await TokenStorage().clear();
    await UserApi.instance.logout();
  }
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
