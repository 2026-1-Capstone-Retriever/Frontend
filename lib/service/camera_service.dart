import 'dart:async';

/// =======================================================
/// CameraService
/// - 앱 전체에서 단 하나만 존재 (Singleton)
/// - 카메라 시작 / 정지 관리
/// - 장애물 데이터 Stream 제공
/// =======================================================

class CameraService {
  // ✅ Singleton 패턴
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  bool _isRunning = false;

  /// 🔔 장애물 데이터 스트림 (나중에 모델 연결)
  final StreamController<dynamic> _obstacleController =
      StreamController.broadcast();

  Stream<dynamic> get obstacleStream => _obstacleController.stream;

  /// ----------------------------------------
  /// 카메라 시작 (실제 구현은 추후 추가)
  /// ----------------------------------------
  Future<void> start() async {
    if (_isRunning) return;

    _isRunning = true;

    // TODO: 카메라 초기화
    // TODO: 소켓 연결
    // TODO: 프레임 스트림 시작

    print("📷 CameraService started");
  }

  /// ----------------------------------------
  /// 카메라 정지
  /// ----------------------------------------
  Future<void> stop() async {
    if (!_isRunning) return;

    _isRunning = false;

    // TODO: 카메라 dispose
    // TODO: 소켓 연결 종료

    print("🛑 CameraService stopped");
  }

  bool get isRunning => _isRunning;

  /// ----------------------------------------
  /// (임시) 테스트용 데이터 emit
  /// ----------------------------------------
  void emitTestData(dynamic data) {
    _obstacleController.add(data);
  }

  /// ----------------------------------------
  /// 앱 종료 시 호출
  /// ----------------------------------------
  void dispose() {
    _obstacleController.close();
  }
}
