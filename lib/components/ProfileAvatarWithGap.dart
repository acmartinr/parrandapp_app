import 'package:flutter/material.dart';
import 'dart:math' as math;

/// ProfileAvatarWithGap.dart
///
/// Este widget dibuja un avatar circular con un borde (arco) que tiene
/// un hueco en la parte superior (notch), muy parecido al efecto de WhatsApp.
/// Usa un CustomPainter (_ArcPainter) para pintar el arco y centra un CircleAvatar
/// en su interior, dejando espacio suficiente para que el notch se vea.
///
/// Ejemplo de uso:
/// ```dart
/// ProfileAvatarWithGap(
///   imageProvider: NetworkImage(avatarUrl),
///   size: 48.0,
///   strokeWidth: 4.0,
///   gapAngle: math.pi / 4, // 45° de hueco
///   borderColor: Color(0xFF24B675), // verde estilo WhatsApp
/// )
/// ```
class ProfileAvatarWithGap extends StatelessWidget {
  /// Imagen que se usará dentro del CircleAvatar.
  final ImageProvider imageProvider;

  /// Tamaño total del widget (ancho y alto).
  final double size;

  /// Grosor del borde (arco exterior).
  final double strokeWidth;

  /// Ángulo del hueco en la parte superior (en radianes).
  final double gapAngle;

  /// Color del arco exterior.
  final Color borderColor;

  const ProfileAvatarWithGap({
    Key? key,
    required this.imageProvider,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.gapAngle = math.pi / 4, // 45° de hueco por defecto
    this.borderColor = const Color(0xFF24B675), // verde estilo WhatsApp
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calcula el diámetro interno: dejamos espacio para el strokeWidth por ambos lados
    final double innerDiameter = size - strokeWidth * 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1) El arco exterior, con gap en la parte superior
          CustomPaint(
            size: Size(size, size),
            painter: _ArcPainter(
              strokeWidth: strokeWidth,
              color: borderColor,
              gapAngle: gapAngle,
            ),
          ),

          // 2) El CircleAvatar centrado, con fondo blanco para despegarlo del arco
          Container(
            width: innerDiameter,
            height: innerDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: innerDiameter / 2,
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pintor que dibuja un arco (borde) alrededor del avatar, dejando un hueco
/// de 'gapAngle' en la parte superior. Usa StrokeCap.round para que los extremos
/// del arco tengan puntas redondeadas (como en WhatsApp).
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
    // Rectángulo donde pintar el arco, ajustado para que el strokeWidth quede dentro
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // puntas redondeadas

    // Inicia justo a la derecha del punto más alto del círculo, desplazado por la mitad del hueco
    final double startAngle = -math.pi / 2 + gapAngle / 2;
    // Barrido que cubre todo menos el hueco
    final double sweepAngle = 2 * math.pi - gapAngle;

    // Deflate rect para que el borde no salga cortado
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