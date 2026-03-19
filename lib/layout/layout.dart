import 'package:flutter/material.dart';
import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/features/detection/detection_screen.dart';
import 'package:safepath/features/home/home_screen.dart';
import 'package:safepath/features/navigation/navigation_screen.dart';
import 'package:safepath/features/settings/settings_screen.dart';
import 'package:safepath/service/camera_service.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  bool _isDetecting = false;

  late final List<Widget> _pages = [
    HomeScreen(onTabChange: _onTap),
    DetectionScreen(onDetectingChanged: (v) => setState(() => _isDetecting = v)),
    const NavigationScreen(),
    const SettingsScreen(),
  ];

  void _onTap(int index) {
    // // 현재 카메라가 필요한 탭에서 벗어나는 경우 카메라 stop
    // if (_needsCamera(_currentIndex) && !_needsCamera(index)) {
    //   CameraService().stop();
    // }
    setState(() {
      _currentIndex = index;
    });

    // // 새 탭이 카메라 필요하면 start
    // if (_needsCamera(index)) {
    //   CameraService().start();
    // }
  }

  bool _needsCamera(int index) {
    // DetectionScreen = 1, NavigationScreen = 2
    return index == 1 || index == 2;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (_isDetecting) return; // 탐지 중이면 뒤로가기 완전 차단
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
        // 홈 탭에서는 뒤로가기 무시 (로그인으로 안 돌아감)
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: ColorCollection.point, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: ColorCollection.background,
          selectedItemColor: ColorCollection.main,
          selectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'NanumSquareNeo',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'NanumSquareNeo',
          ),
          unselectedItemColor: ColorCollection.point,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(
              icon: Icon(Icons.remove_red_eye_outlined),
              label: '탐지',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.navigation), label: '길찾기'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
          ],
        ),
      ),
      ),
    );
  }
}

