import 'package:flutter/material.dart';
import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/theme/text_styles.dart';

class TextInputBar extends StatelessWidget {
  final TextEditingController controller; // 텍스트 컨트롤러
  final String? hintText; // 힌트 텍스트
  final bool showSearchIcon; // 검색 아이콘 표시 여부 (default : true)
  final VoidCallback? micTap; // 음성 텍스트 입력 아이콘
  final ValueChanged<String>? onSubmitted;

  const TextInputBar({
    super.key,
    required this.controller,
    this.hintText,
    this.showSearchIcon = true,
    this.micTap,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.labelRegular.copyWith(
              color: ColorCollection.point,
            ),
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              prefixIcon: showSearchIcon
                  ? const Icon(Icons.search, color: ColorCollection.main)
                  : null,
              suffixIcon: ValueListenableBuilder(
                valueListenable: controller,
                builder: (context, value, child) {
                  if (value.text.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    icon: const Icon(Icons.close, color: ColorCollection.main),
                    onPressed: () {
                      controller.clear();
                    },
                  );
                },
              ),
              hintText: hintText,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 12,
              ),
              filled: true,
              fillColor: ColorCollection.background,
              hintStyle: AppTextStyles.labelRegular.copyWith(
                color: ColorCollection.point,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorCollection.main, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: ColorCollection.main, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: micTap,
            child: Container(
              width: 55,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorCollection.main,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.mic,
                color: ColorCollection.point,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
