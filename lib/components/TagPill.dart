import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lexi/components/TagPillPainter.dart';

class TagPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const TagPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: TagPillPainter(selected),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Color(0xFF1D1B20),
              fontWeight: FontWeight.w600,
              fontSize: 16,
              fontFamily: 'SourceSansProBold',
            ),
          ),
        ),
      ),
    );
  }
}
