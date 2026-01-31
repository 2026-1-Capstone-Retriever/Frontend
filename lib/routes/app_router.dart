import 'package:flutter/material.dart';
import 'package:safepath/features/home/home_screen.dart';
import 'package:safepath/features/settings/settings_screen.dart';

/// ========================================================================
/// 사용 예시:
///
/// 1. 다른 화면으로 이동
/// Navigator.pushNamed(context, AppRouter.settings);
///
/// 2. 이동 후 현재 화면 제거 (뒤로가기 불가)
/// Navigator.pushReplacementNamed(context, AppRouter.home);
///
/// 3. 이전 화면으로 돌아가기
/// Navigator.pop(context);
/// ========================================================================
///
///
/// ========================================================================
/// 새 화면 추가시 설정 방법
/// ========================================================================
///
/// 1. app_router.dart에 경로 추가
/// static const String navigation = '/navigation';
///
/// 2. switch문에 케이스 추가
/// case navigation:
///   return MaterialPageRoute(builder: (_) => const NavigationScreen());
///
/// ========================================================================
class AppRouter {
  static const String home = '/';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRouter.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('페이지를 찾을 수 없습니다'))),
        );
    }
  }
}
