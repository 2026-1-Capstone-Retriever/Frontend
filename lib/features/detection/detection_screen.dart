import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/detection/detection_active_view.dart';
import 'package:safepath/features/detection/detection_idle_view.dart';
import 'package:safepath/service/camera_service.dart';

class DetectionScreen extends StatefulWidget {
  final ValueChanged<bool>? onDetectingChanged;

  const DetectionScreen({super.key, this.onDetectingChanged});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  bool _isDetecting = false;

  // TODO: 실제 탐지 로직 연결 시 여기서 카메라/모델 제어
  int _detectedCount = 0;

  Future<void> _startDetection() async {
    await CameraService().start(CameraMode.detection);
    // 가로 모드로 전환
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    setState(() {
      _isDetecting = true;
      _detectedCount = 0;
    });
    widget.onDetectingChanged?.call(true);
  }

  Future<void> _stopDetection() async {
    await CameraService().stop();
    // 세로 모드로 복원
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() {
      _isDetecting = false;
    });
    widget.onDetectingChanged?.call(false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDetecting,
      child: Scaffold(
        // active 상태일 때 AppBar 없음
        appBar: _isDetecting
            ? null
            : const CustomTitleBar(title: '실외 장애물 탐지'),
        body: SafeArea(
          child: _isDetecting
              ? DetectionActiveView(
                  onStop: _stopDetection,
                  detectedCount: _detectedCount,
                )
              : DetectionIdleView(onStart: _startDetection),
        ),
      ),
    );
  }
}
