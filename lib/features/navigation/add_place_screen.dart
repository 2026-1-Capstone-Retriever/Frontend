import 'package:flutter/material.dart';
import 'package:safepath/common/enum/place_category.dart';
import 'package:safepath/common/widgets/action_button_widget.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/navigation/address_section.dart';
import 'package:safepath/features/navigation/category_section.dart';
import 'package:safepath/features/navigation/place_name_section.dart';
import 'package:safepath/models/saved_place.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AddPlaceScreen extends StatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  State<AddPlaceScreen> createState() => _AddPlaceScreenState();
}

class _AddPlaceScreenState extends State<AddPlaceScreen> {
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController placeNameController = TextEditingController();
  final stt.SpeechToText speech = stt.SpeechToText();

  /// 텍스트 입력 여부 확인
  bool get _hasDestination => destinationController.text.trim().isNotEmpty;
  bool get _hasPlaceName => placeNameController.text.trim().isNotEmpty;

  /// 위치 변수
  String currentLocation = "검색창에서 위치를 검색하세요.";

  /// 선택된 카테고리
  PlaceCategory? selectedCategory;

  @override
  void initState() {
    super.initState();
    speech.initialize();

    destinationController.addListener(_onTextChanged);
    placeNameController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    destinationController.removeListener(_onTextChanged);
    placeNameController.removeListener(_onTextChanged);

    destinationController.dispose();
    placeNameController.dispose();
    super.dispose();
  }

  /// 음성 텍스트 입력 함수
  void startSpeechInput(TextEditingController controller) async {
    // 음성 인식 중복 실행 방지 - 다시 한 번 더 누르면 중지
    if (speech.isListening) {
      await speech.stop();
      return;
    }
    speech.listen(
      pauseFor: const Duration(seconds: 2), // 2초 동안 말이 없으면 자동으로 듣기 종료
      listenFor: const Duration(seconds: 10), // 최대 듣기 시간
      localeId: "ko_KR",
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          setState(() {
            controller.text = result.recognizedWords;
          });
        }
      },
    );
  }

  /// 장소 추가 함수
  void addPlace() {
    if (selectedCategory == null) return;

    final newPlace = SavedPlace(
      label: placeNameController.text,
      location: currentLocation,
      category: selectedCategory!,
    );

    Navigator.pop(context, newPlace);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '장소 추가하기', showBackButton: true),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddressSection(
                        controller: destinationController,
                        currentLocation: currentLocation,
                        onSubmitted: (value) {
                          setState(() {
                            currentLocation = value;
                          });
                        },
                        onClear: () {
                          setState(() {
                            currentLocation = "검색창에서 위치를 검색하세요.";
                          });
                        },
                        onMicTap: () => startSpeechInput(destinationController),
                      ),
                      const SizedBox(height: 30),
                      PlaceNameSection(
                        controller: placeNameController,
                        onMicTap: () => startSpeechInput(placeNameController),
                      ),
                      const SizedBox(height: 30),
                      CategorySection(
                        selectedCategory: selectedCategory,
                        onSelected: (category) {
                          setState(() {
                            if (selectedCategory == category) {
                              selectedCategory = null; // 다시 누르면 해제
                            } else {
                              selectedCategory = category; // 선택
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: ActionButton(
                    label: '추가하기',
                    icon: Icons.check_circle_outline_rounded,
                    onTap:
                        (_hasDestination &&
                            _hasPlaceName &&
                            selectedCategory != null)
                        ? addPlace
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
