import 'package:flutter/material.dart';

class BadgeIconButton extends StatelessWidget {
  final String assetPath;
  final int count;
  final double iconSize;
  final VoidCallback onPressed;
  final double badgeSize;

  const BadgeIconButton({
    Key? key,
    required this.assetPath,
    required this.count,
    required this.onPressed,
    this.iconSize = 32,
    this.badgeSize = 26,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // permite que el badge se salga de los límites
      children: [
        IconButton(
          iconSize: iconSize,
          onPressed: onPressed,
          icon: Image.asset(assetPath),
        ),
        if (count > 0)
          Positioned(
            // ajusta la posición del badge relativo al botón
            right: 4,
            top: 4,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
