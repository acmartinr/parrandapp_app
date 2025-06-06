import 'package:flutter/material.dart';
import 'dart:math' as math;

/// action_card_circle.dart
///
/// Widget circular con arco y espacio simétrico en la parte superior.
/// Muestra un aro rodeando un círculo interior con texto, dejando un hueco en la parte superior
/// de forma que las dos puntas del arco nunca se toquen.
class ActionCardCircle extends StatelessWidget {
  /// Controla la visibilidad: opacidad 1.0 si true, 0.0 si false.
  final bool show;

  /// Tamaño total del widget (ancho y alto).
  final double size;

  /// Grosor del aro exterior.
  final double strokeWidth;

  /// Ángulo de hueco en la parte superior (en radianes).
  final double gapAngle;

  /// Texto central.
  final String text;

  /// Color principal para aro y círculo.
  final Color color;

  const ActionCardCircle({
    Key? key,
    required this.show,
    required this.text,
    required this.color,
    this.size = 150.0,
    this.strokeWidth = 8.0,
    this.gapAngle = math.pi / 5, // 60° de hueco
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula el tamaño del círculo interior para aumentar separación
    final double innerSize = size - strokeWidth * 3.2;

    return Opacity(
      opacity: show ? 1.0 : 0.0,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Arco con CustomPainter
            CustomPaint(
              size: Size(size, size),
              painter: _ArcPainter(
                strokeWidth: strokeWidth,
                color: color,
                gapAngle: gapAngle,
              ),
            ),
            // Círculo interior con texto, ahora más pequeño para separar del aro
            Container(
              width: innerSize,
              height: innerSize,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                text,
                style: const TextStyle(
                  decoration: TextDecoration.none,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Pintor personalizado para dibujar el arco exterior con hueco.
class _ArcPainter extends CustomPainter {
  final double strokeWidth;
  final double gapAngle;
  final Color color;

  _ArcPainter({
    required this.strokeWidth,
    required this.gapAngle,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    // Inicia en el centro arriba más la mitad del hueco hacia la derecha
    final double startAngle = -math.pi / 2 + gapAngle / 2;
    // Barrido que cubre todo menos el hueco
    final double sweepAngle = 2 * math.pi - gapAngle;
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) {
    return old.strokeWidth != strokeWidth ||
        old.gapAngle != gapAngle ||
        old.color != color;
  }
}

// Ejemplo de uso:
// import 'action_card_circle.dart';
//
// Positioned(
//   top: 100,
//   left: 50,
//   child: ActionCardCircle(show: showYesIndicator),
// );
