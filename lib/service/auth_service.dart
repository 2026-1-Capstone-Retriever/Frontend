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
  /// 반환값: AuthResult (isNewUser 포함)
  Future<AuthResult> signInWithKakao() async {
    const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
    final redirectUri = 'kakao$kakaoNativeAppKey://oauth';

    String authCode;
    try {
      final kakaoTalkInstalled = await isKakaoTalkInstalled();
      debugPrint('🟡 [Auth] 카카오톡 설치 여부: $kakaoTalkInstalled');

      if (kakaoTalkInstalled) {
        authCode = await AuthCodeClient.instance.authorizeWithTalk(redirectUri: redirectUri);
        debugPrint('🟡 [Auth] 카카오톡 앱으로 인가 코드 발급 성공');
      } else {
        authCode = await AuthCodeClient.instance.authorize(redirectUri: redirectUri);
        debugPrint('🟡 [Auth] 카카오 계정(웹)으로 인가 코드 발급 성공');
      }
    } catch (e) {
      debugPrint('🔴 [Auth] 카카오 로그인 실패: $e');
      throw AuthException('카카오 로그인 실패: $e');
    }

    return await _fetchTokenFromServer(authCode);
  }

  Future<AuthResult> _fetchTokenFromServer(String accessToken) async {
    final uri = Uri.parse('$_baseUrl/api/auth/kakao/callback?code=$accessToken');
    debugPrint('🟡 [Auth] BE 요청: GET $uri');

    final response = await http.get(uri);
    debugPrint('🟡 [Auth] BE 응답: ${response.statusCode} / ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = jsonDecode(response.body);
      await TokenStorage().saveTokens(
        accessToken: body['accessToken'] as String,
        refreshToken: body['refreshToken'] as String,
      );
      final isNewUser = response.statusCode == 201;
      debugPrint('✅ [Auth] 토큰 저장 완료 / 신규 유저: $isNewUser');
      return AuthResult(isNewUser: isNewUser);
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

/// 로그인 결과
class AuthResult {
  /// true = 신규 유저 (회원가입), false = 기존 유저 (로그인)
  final bool isNewUser;
  const AuthResult({required this.isNewUser});
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
