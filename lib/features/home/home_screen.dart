import 'package:flutter/material.dart';
import 'package:safepath/common/widgets/logo_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: Center(child: LogoWidget())),
    );
  }
}
