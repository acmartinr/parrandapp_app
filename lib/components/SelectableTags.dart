import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lexi/components/TagSelectorController.dart';

class SelectableTags extends StatelessWidget {
  final List<String> tags;
  final TagSelectorController controller;
  final int maxSelection; // puedes limitar la selección máxima

  SelectableTags({
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
          spacing: 12,
          runSpacing: 12,
          children: List.generate(tags.length, (i) {
            final isSelected = controller.selectedIndexes.contains(i);
            return GestureDetector(
              onTap: () {
                if (isSelected ||
                    controller.selectedIndexes.length < maxSelection) {
                  controller.toggle(i);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            'Solo puedes seleccionar $maxSelection intereses')),
                  );
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Color(0xFF0057FF) : Colors.transparent,
                  border: Border.all(color: Color(0xFF0057FF), width: 1.3),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Text(
                  tags[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Color(0xFF1D1B20),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'SourceSansProBold',
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
