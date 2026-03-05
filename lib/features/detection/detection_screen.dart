import 'package:flutter/material.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';

class DetectionScreen extends StatelessWidget {
  const DetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '실외 장애물 탐지'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '실외 장애물 탐지',
                style: AppTextStyles.title2.copyWith(
                  color: ColorCollection.point,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
