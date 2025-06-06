import 'package:flutter/material.dart';

class TagSelectorController extends ChangeNotifier {
  final List<int> selectedIndexes = [];

  void toggle(int index) {
    if (selectedIndexes.contains(index)) {
      selectedIndexes.remove(index);
    } else {
      selectedIndexes.add(index);
    }
    notifyListeners();
  }

  void clear() {
    selectedIndexes.clear();
    notifyListeners();
  }
}

class TagSelector extends StatelessWidget {
  final List<String> tags;
  final TagSelectorController controller;
  final int maxSelection;

  TagSelector({
    required this.tags,
    required this.controller,
    this.maxSelection = 5,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Wrap(
          spacing: 6,     // Espacio horizontal entre chips
          runSpacing: 14,  // Espacio vertical entre filas de chips
          children: List.generate(tags.length, (i) {
            final isSelected = controller.selectedIndexes.contains(i);
            return GestureDetector(
              onTap: () {
                if (isSelected || controller.selectedIndexes.length < maxSelection) {
                  controller.toggle(i);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Solo puedes seleccionar $maxSelection intereses')),
                  );
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 170),
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF056A9E) : Colors.transparent,
                  border: Border.all(
                    color: Color(0xFFADACCA), // Borde azul-gris clarito
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  tags[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF1D1B20),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'SourceSansProNormal',
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}