import 'package:flutter/material.dart';
import 'package:safepath/common/enum/place_category.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/navigation/edit_button.dart';
import 'package:safepath/features/navigation/saved_place_widget.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '길찾기'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '저장된 장소',
                    style: AppTextStyles.title2.copyWith(
                      color: ColorCollection.point,
                      fontSize: 20,
                    ),
                  ),
                  EditButton(),
                ],
              ),
              const SizedBox(height: 25),
              SavedPlaceWidget(
                label: '집',
                location: '서울특별시 성북구 솔샘로8길',
                category: PlaceCategory.home,
              ),
              const SizedBox(height: 25),
              Text(
                '최근 장소',
                style: AppTextStyles.title2.copyWith(
                  color: ColorCollection.point,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 25),
              SavedPlaceWidget(label: '집', location: '서울특별시 성북구 솔샘로8길'),
            ],
          ),
        ),
      ),
    );
  }
}
