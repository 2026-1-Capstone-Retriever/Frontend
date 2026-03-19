import 'package:flutter/material.dart';
import 'package:safepath/common/theme/text_styles.dart';

import 'package:safepath/routes/app_router.dart';
import 'package:safepath/common/widgets/logo_widget.dart';
import 'package:safepath/common/widgets/button_widget.dart';
import 'package:safepath/common/theme/color_collection.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 33),
            const Center(child: LogoWidget()),
            const SizedBox(height: 63),
            CustomButton(
              width: 344,
              height: 218,
              title: '시작하기',
              titleSubtitleSpacing: 17,
              subtitle: '카카오계정으로 시작',
              backgroundColor: ColorCollection.main,
              titleColor: ColorCollection.background,
              titleStyle: AppTextStyles.headline,
              subtitleColor: ColorCollection.background,
              subtitleStyle: AppTextStyles.bodyBold,
              borderColor: ColorCollection.main,
              onTap: () => Navigator.pushNamed(context, AppRouter.home),
            ),
            SizedBox(height: 28),
            CustomButton(
              width: 344,
              height: 218,
              title: '사용 방법',
              titleSubtitleSpacing: 17,
              subtitle: '사용 가이드 보기',
              backgroundColor: ColorCollection.background,
              titleColor: ColorCollection.point,
              titleStyle: AppTextStyles.headline,
              subtitleColor: ColorCollection.point,
              subtitleStyle: AppTextStyles.bodyBold,
              borderColor: ColorCollection.point,
              onTap: () => Navigator.pushNamed(context, AppRouter.userguide),
            ),
          ],
        ),
      ),
    );
  }
}
