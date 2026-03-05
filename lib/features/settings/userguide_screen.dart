import 'package:flutter/material.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';

import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/theme/text_styles.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '사용 방법', showBackButton: true),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사용 방법', style: AppTextStyles.title1),
              const SizedBox(height: 24),
              Text('사용 방법 설명', style: AppTextStyles.bodyRegular),
            ],
          ),
        ),
      ),
    );
  }
}
