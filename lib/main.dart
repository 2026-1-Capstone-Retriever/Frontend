import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:safepath/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: 카카오 디벨로퍼스(https://developers.kakao.com)에서 앱 등록 후 Native App Key 입력
  KakaoSdk.init(nativeAppKey: 'YOUR_KAKAO_NATIVE_APP_KEY');

  runApp(const App());
}
