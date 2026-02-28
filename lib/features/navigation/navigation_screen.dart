import 'package:flutter/material.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/common/theme/color_collection.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '길찾기',
          style: AppTextStyles.title2.copyWith(color: ColorCollection.point),
        ),
        backgroundColor: ColorCollection.main,
        iconTheme: const IconThemeData(color: ColorCollection.point),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '길찾기',
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
