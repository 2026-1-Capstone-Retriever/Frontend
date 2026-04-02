import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

/// 카메라 사용 모드
enum CameraMode { detection, navigation }

/// =======================================================
/// CameraService
///
/// 역할:
///   - 후면 카메라 초기화 (프리뷰 없이 프레임만 수집)
///   - 주기적으로 프레임 캡처 → 백엔드 전송
///   - Detection / Navigation 모드 공용 사용
///
/// 호출 위치:
///   - DetectionScreen: 탐지 시작 버튼 → start() / 중지 버튼 → stop()
///   - NavigationScreen: 길찾기 시작 → start() / 종료 → stop()
///   - Layout에서 탭 전환으로 제어하지 않음 (모드 시작·종료 시점에 제어)
///
/// 사용 예시:
///   await CameraService().start(CameraMode.detection);
///   await CameraService().stop();
/// =======================================================
class CameraService {
  // Singleton
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  // TODO: 백엔드 서버 URL 설정
  static const String _detectionEndpoint = 'https://your-server.com/api/detection/frame';
  static const String _navigationEndpoint = 'https://your-server.com/api/navigation/frame';

  /// 캡처 주기 (초)
  static const Duration _captureInterval = Duration(seconds: 1);

  CameraController? _controller;
  Timer? _captureTimer;
  CameraMode? _currentMode;
  bool _isRunning = false;

  bool get isRunning => _isRunning;
  CameraMode? get currentMode => _currentMode;

  // ─── 시작 ─────────────────────────────────────────────────────────────────

  Future<void> start(CameraMode mode) async {
    if (_isRunning) return;

    try {
      final cameras = await availableCameras();
      final rear = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        rear,
        ResolutionPreset.medium, // 서버 전송용 — 고해상도 불필요
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      _isRunning = true;
      _currentMode = mode;

      // 주기적 캡처 시작
      _captureTimer = Timer.periodic(_captureInterval, (_) => _captureAndSend());
    } catch (e) {
      // 카메라 권한 거부, 하드웨어 오류 등
      _isRunning = false;
      rethrow;
    }
  }

  // ─── 정지 ─────────────────────────────────────────────────────────────────

  Future<void> stop() async {
    if (!_isRunning) return;

    _captureTimer?.cancel();
    _captureTimer = null;

    await _controller?.dispose();
    _controller = null;

    _isRunning = false;
    _currentMode = null;
  }

  // ─── 프레임 캡처 & 전송 ───────────────────────────────────────────────────

  Future<void> _captureAndSend() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final file = await _controller!.takePicture();
      final bytes = await file.readAsBytes();
      await _sendFrame(bytes);
    } catch (_) {
      // 전송 실패 시 다음 주기에 재시도 — 별도 처리 없음
    }
  }

  Future<void> _sendFrame(Uint8List bytes) async {
    final endpoint = _currentMode == CameraMode.detection
        ? _detectionEndpoint
        : _navigationEndpoint;

    final request = http.MultipartRequest('POST', Uri.parse(endpoint))
      ..files.add(
        http.MultipartFile.fromBytes(
          'frame',
          bytes,
          filename: 'frame_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );

    // TODO: 인증 헤더 추가 (Bearer token 등)
    // request.headers['Authorization'] = 'Bearer $token';

    await request.send();
  }
}
