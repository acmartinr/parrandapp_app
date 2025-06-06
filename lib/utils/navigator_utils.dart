import 'package:flutter/material.dart';

class NavigatorUtils {
  /// Navegación con animación de izquierda a derecha (pushReplacement)
  static void pushReplacementSlideLeft(BuildContext context, Widget page,
      {int milliseconds = 400}) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: milliseconds),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0), // Desde la derecha
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut));

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  /// Navegación normal con animación de izquierda a derecha (push)
  static void pushSlideLeft(BuildContext context, Widget page,
      {int milliseconds = 400}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: Duration(milliseconds: milliseconds),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut));
          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }
}
