import 'dart:math';

import 'package:flutter/material.dart';

import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/features/detection/detection_button_widget.dart';
import 'package:safepath/features/detection/obstacle_card_widget.dart';

// TODO: 실제 AI 탐지 결과 연결 시 더미 데이터 제거
const _dummyObstacles = [
  (
    name: '자전거',
    distance: '가까움',
    position: '정면',
    vibration: '강한 진동 (연이은 진동)',
    proximity: ObstacleProximity.near,
  ),
  (
    name: '전봇대',
    distance: '중간',
    position: '왼쪽',
    vibration: '중간 진동 (2회)',
    proximity: ObstacleProximity.mid,
  ),
  (
    name: '가로수',
    distance: '멂',
    position: '오른쪽',
    vibration: '약한 진동 (1회)',
    proximity: ObstacleProximity.far,
  ),
];

/// 탐지 진행 화면 (탐지 중)
class DetectionActiveView extends StatelessWidget {
  final VoidCallback onStop;

  /// 탐지된 물체 총 수
  final int detectedCount;

  const DetectionActiveView({
    super.key,
    required this.onStop,
    required this.detectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 탐지 중지 버튼
          Center(
            child: DetectionButton(isDetecting: true, onTap: onStop, size: 180),
          ),
          const SizedBox(height: 20),

          // 실시간 감지 활성화 상태 표시
          Semantics(
            label: '실시간 감지 활성화 중',
            excludeSemantics: true,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: ColorCollection.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '실시간 감지 활성화',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: ColorCollection.point,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 탐지된 물체 수 박스
          Semantics(
            label: '탐지된 물체 $detectedCount개',
            excludeSemantics: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: ColorCollection.point.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: ColorCollection.main, width: 3),
              ),
              child: Column(
                children: [
                  Text(
                    '$detectedCount',
                    style: AppTextStyles.title1.copyWith(
                      color: ColorCollection.main,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '탐지된 물체',
                    style: AppTextStyles.bodyRegular.copyWith(
                      color: ColorCollection.point,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 감지된 장애물 섹션 (이 영역만 스크롤)
          Text(
            '감지된 장애물',
            style: AppTextStyles.title2.copyWith(color: ColorCollection.point),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              itemCount: _dummyObstacles.length, // TODO: 실제 탐지 결과로 교체
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final o = _dummyObstacles[index];
                return ObstacleCard(
                  name: o.name,
                  distance: o.distance,
                  position: o.position,
                  vibration: o.vibration,
                  proximity: o.proximity,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 탐지 중 로딩 표시
class _LoadingIndicator extends StatefulWidget {
  @override
  State<_LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<_LoadingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '주변을 탐지하고 있습니다.',
      excludeSemantics: true,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                size: const Size(40, 40),
                painter: _LoadingPainter(progress: _controller.value),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '주변을 탐지하고 있습니다.',
              style: AppTextStyles.labelRegular.copyWith(
                color: ColorCollection.point,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPainter extends CustomPainter {
  final double progress;

  _LoadingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 5.0;
    final radius = (size.width - strokeWidth) / 2;

    const gapAngle = 60 * pi / 180;
    const orangeSweep = 50 * pi / 180;

    final orangeStart = 2 * pi * progress - pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      orangeStart + orangeSweep + gapAngle / 2,
      2 * pi - orangeSweep - gapAngle,
      false,
      Paint()
        ..color = ColorCollection.point
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      orangeStart,
      orangeSweep,
      false,
      Paint()
        ..color = ColorCollection.main
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_LoadingPainter old) => old.progress != progress;
}
