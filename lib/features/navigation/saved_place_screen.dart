import 'package:flutter/material.dart';
import 'package:safepath/common/widgets/action_button_widget.dart';
import 'package:safepath/common/widgets/title_bar_widget.dart';
import 'package:safepath/features/navigation/saved_place_widget.dart';
import 'package:safepath/data/saved_place_dummy.dart';

class SavedPlaceScreen extends StatefulWidget {
  const SavedPlaceScreen({super.key});

  @override
  State<SavedPlaceScreen> createState() => _SavedPlaceScreenState();
}

class _SavedPlaceScreenState extends State<SavedPlaceScreen> {
  bool isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomTitleBar(title: '저장된 장소', showBackButton: true),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: savedPlaces.length,
                  itemBuilder: (context, index) {
                    final place = savedPlaces[index];

                    return SavedPlaceWidget(
                      label: place.label,
                      location: place.location,
                      category: place.category,
                      isEditMode: isEditMode,
                    );
                  },
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 21),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: ActionButton(
                    label: isEditMode ? '저장하기' : '편집하기',
                    icon: isEditMode
                        ? Icons.check_circle_outline_rounded
                        : Icons.edit,
                    onTap: () {
                      setState(() {
                        isEditMode = !isEditMode;
                      });
                    },
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
