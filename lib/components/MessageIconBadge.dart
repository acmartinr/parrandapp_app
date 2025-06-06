import 'package:flutter/material.dart';

/// Un widget que muestra un badge con contador (rojo) en la esquina superior derecha de su [child].
class MessageIconBadge extends StatelessWidget {
  /// Widget sobre el cual se posicionará el badge.
  final Widget child;

  /// Contador de elementos a mostrar. Si es null o <=0, no muestra el badge.
  final int? count;

  /// Tamaño mínimo del badge (diámetro) en píxeles.
  final double size;

  /// Desplazamiento del badge respecto a la esquina (x e y en píxeles).
  final Offset offset;

  const MessageIconBadge({
    Key? key,
    required this.child,
    this.count,
    this.size = 24.0,
    this.offset = const Offset(0, 0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count != null && count! > 0)
          Positioned(
            right: -offset.dx,
            top: -offset.dy,
            child: IgnorePointer(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.0),
                constraints: BoxConstraints(
                  minWidth: size,
                  minHeight: size,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    count! > 99 ? '99+' : count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.6,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
