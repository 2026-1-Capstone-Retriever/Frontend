import 'package:flutter/material.dart';
import 'package:safepath/common/enum/place_category.dart';
import 'package:safepath/common/theme/text_styles.dart';
import 'package:safepath/common/theme/color_collection.dart';
import 'package:safepath/common/widgets/action_button_widget.dart';
import 'package:safepath/common/widgets/text_input_bar.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/navigation/current_place_widget.dart';
import 'package:safepath/features/navigation/more_button.dart';
import 'package:safepath/features/navigation/saved_place_widget.dart';
import 'package:safepath/data/saved_place_dummy.dart';
import 'package:safepath/routes/app_router.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final TextEditingController destinationController = TextEditingController();
  final stt.SpeechToText speech = stt.SpeechToText();

  /// 텍스트 입력 여부 확인
  bool get _hasDestination => destinationController.text.trim().isNotEmpty;

  /// 위치 변수
  String currentLocation = "현재 위치 불러오는 중...";
  String selectedLocation = "목적지를 선택해 주세요.";

  @override
  void initState() {
    super.initState();
    speech.initialize();
    destinationController.addListener(() {
      setState(() {});
    });

    loadLocation();
  }

  /// destinationController의 listener 해제
  @override
  void dispose() {
    destinationController.dispose();
    super.dispose();
  }

  /// 음성 텍스트 입력 함수
  void startSpeechInput() async {
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
            destinationController.text = result.recognizedWords;
          });
        }
      },
    );
  }

  /// 길찾기 시작 함수
  void startNavigation() {
    // 키보드 먼저 닫기
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.pushNamed(context, AppRouter.navigationing).then((_) {
      // 돌아왔을 때 입력값 초기화
      destinationController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  /// 현재 위치 가져오기
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스 활성화 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 꺼져 있습니다.');
    }

    // 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 거부되었습니다.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다.');
    }

    // 현재 위치 가져오기
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void loadLocation() async {
    try {
      final position = await getCurrentLocation();

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
        localeIdentifier: "ko_KR",
      );

      Placemark place = placemarks.first;

      // administrativeArea : 서울특별시
      // subAdministrativeArea : 성북구
      // thoroughfare : 정릉로
      // subThoroughfare : 77

      String address = [
        place.administrativeArea,
        place.subAdministrativeArea,
        place.locality,
        place.subLocality,
        place.thoroughfare,
        place.subThoroughfare,
      ].where((e) => e != null && e!.isNotEmpty).join(' ');

      setState(() {
        currentLocation = address;
      });
    } catch (e) {
      setState(() {
        currentLocation = "위치 불러오기 실패";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '길찾기'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 목적지 입력 섹션
                TextInputBar(
                  controller: destinationController,
                  hintText: '목적지를 입력하세요',
                  micTap: startSpeechInput,
                  onSubmitted: (_) {
                    if (_hasDestination) {
                      startNavigation();
                    }
                  },
                ),
                const SizedBox(height: 16),
                CurrentPlaceWidget(label: '현재 위치', location: currentLocation),
                const SizedBox(height: 16),
                CurrentPlaceWidget(label: '목적지 위치', location: selectedLocation),
                const SizedBox(height: 16),
                ActionButton(
                  label: '안내 시작',
                  icon: Icons.play_circle_outline_outlined,
                  onTap: _hasDestination ? startNavigation : null,
                ),
                const SizedBox(height: 30),

                /// 저장된 장소 섹션
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
                    MoreButton(
                      onTap: () async {
                        final place = await Navigator.pushNamed(
                          context,
                          AppRouter.savedplace,
                        );

                        if (place != null) {
                          setState(() {
                            destinationController.text =
                                (place as dynamic).label;
                            selectedLocation = (place as dynamic).location;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                ...savedPlaces.take(2).map((place) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: SavedPlaceWidget(
                      label: place.label,
                      location: place.location,
                      category: place.category,
                      onTap: () {
                        setState(() {
                          destinationController.text = place.label;
                          selectedLocation = place.location;
                        });
                      },
                    ),
                  );
                }).toList(),

                /// 최근 장소 섹션
                Text(
                  '최근 장소',
                  style: AppTextStyles.title2.copyWith(
                    color: ColorCollection.point,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 25),
                SavedPlaceWidget(
                  label: '회사',
                  location: '서울특별시 성북구 솔샘로98길',
                  onTap: () {
                    setState(() {
                      destinationController.text = '회사';
                    });
                  },
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
