import 'package:flutter/material.dart';

import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/settings/settings_info_widget.dart';
import 'package:safepath/features/settings/settings_notification_widget.dart';
import 'package:safepath/features/settings/settings_profile_widget.dart';
import 'package:safepath/features/settings/settings_style_widget.dart';
import 'package:safepath/routes/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(title: '설정'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 유저 프로필
              SettingsProfileWidget(
                name: '홍길동',
                onTap: () {}, // TODO: 프로필 편집 페이지 연결
              ),
              const SizedBox(height: 32),

              // 안내 스타일 개인화
              _SectionTitle(title: '안내 스타일 개인화'),
              const SizedBox(height: 12),
              const SettingsStyleWidget(),
              const SizedBox(height: 32),

              // 알림 및 소리
              _SectionTitle(title: '알림 및 소리'),
              const SizedBox(height: 12),
              const SettingsNotificationWidget(),
              const SizedBox(height: 32),

              // 앱 정보
              _SectionTitle(title: '앱 정보'),
              const SizedBox(height: 12),
              SettingsInfoWidget(
                items: [
                  SettingsInfoItem(
                    icon: Icons.info_outline,
                    label: '앱 정보',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.appinfo),
                  ),
                  SettingsInfoItem(
                    icon: Icons.help_outline,
                    label: '사용 방법',
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.userguide),
                  ),
                  SettingsInfoItem(
                    icon: Icons.description_outlined,
                    label: '이용 약관',
                    onTap: () => Navigator.pushNamed(context, AppRouter.term),
                  ),
                  SettingsInfoItem(
                    icon: Icons.shield_outlined,
                    label: '개인정보 처리 방침',
                    onTap: () => Navigator.pushNamed(context, AppRouter.policy),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.title2.copyWith(color: ColorCollection.point),
    );
  }
}
