import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TagPillPainter extends CustomPainter {
  final bool selected;

  TagPillPainter(this.selected);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = selected ? Color(0xFF0057FF) : Colors.transparent
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Color(0xFFB5B7C4)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final radius = Radius.circular(100);
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      radius,
    );

    // Fondo (relleno)
    canvas.drawRRect(rrect, paint);

    // Línea cortada
    final path = Path()..addRRect(rrect);
    final dashWidth = 30.0;
    final gapWidth = 16.0;
    final totalLength = (2 * pi * radius.x) * 0.75; // aproximado
    double start = 0.0;

    // Dibujamos solo parte del borde (dejamos hueco arriba)
    canvas.save();
    final rect = Offset.zero & size;
    canvas.clipRect(rect);

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      while (start < metric.length) {
        final end = start + dashWidth;
        if (start > metric.length * 0.2 && start < metric.length * 0.8) {
          // Saltamos este tramo (zona de corte)
          start += dashWidth + gapWidth;
          continue;
        }
        canvas.drawPath(metric.extractPath(start, end), borderPaint);
        start += dashWidth + gapWidth;
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
