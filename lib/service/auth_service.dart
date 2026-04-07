import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:safepath/service/token_storage.dart';

/// =======================================================
/// AuthService
///
/// 역할:
///   - 카카오 SDK로 accessToken 받기
///   - BE /api/auth/kakao/callback?code={accessToken} 호출
///   - 토큰 저장/재발급/로그아웃
///
/// BASE_URL은 .env.json → dart-define으로 주입
/// =======================================================
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _baseUrl = String.fromEnvironment('BASE_URL');

  // ─── 카카오 로그인 ────────────────────────────────────────────────────────

  /// 카카오 로그인 후 BE JWT 저장
  /// 성공 시 true, 실패 시 예외 throw
  Future<bool> signInWithKakao() async {
    String accessToken;
    try {
      final kakaoTalkInstalled = await isKakaoTalkInstalled();
      debugPrint('🟡 [Auth] 카카오톡 설치 여부: $kakaoTalkInstalled');

      if (kakaoTalkInstalled) {
        final token = await UserApi.instance.loginWithKakaoTalk();
        accessToken = token.accessToken;
        debugPrint('🟡 [Auth] 카카오톡 앱으로 로그인 성공');
      } else {
        final token = await UserApi.instance.loginWithKakaoAccount();
        accessToken = token.accessToken;
        debugPrint('🟡 [Auth] 카카오 계정(웹)으로 로그인 성공');
      }
    } catch (e) {
      debugPrint('🔴 [Auth] 카카오 로그인 실패: $e');
      throw AuthException('카카오 로그인 실패: $e');
    }

    return await _fetchTokenFromServer(accessToken);
  }

  Future<bool> _fetchTokenFromServer(String accessToken) async {
    final uri = Uri.parse('$_baseUrl/api/auth/kakao/callback?code=$accessToken');
    debugPrint('🟡 [Auth] BE 요청: GET $uri');

    final response = await http.get(uri);
    debugPrint('🟡 [Auth] BE 응답: ${response.statusCode} / ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      await TokenStorage().saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      debugPrint('✅ [Auth] 토큰 저장 완료');
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

    if (refreshToken != null) {
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
