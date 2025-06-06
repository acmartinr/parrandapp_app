import 'package:flutter/cupertino.dart';

/// Ruta que desliza la pantalla actual a la derecha
/// mientras la siguiente entra desde la izquierda.
class SlideBothRouteReverse<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideBothRouteReverse({ required this.page })
      : super(
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secAnim) => page,
    transitionsBuilder: (ctx, anim, secAnim, child) {
      // Animación de entrada: de la izquierda (-1.0) a la posición normal (0.0)
      final inTween = Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));

      // Animación de salida: de la posición normal (0.0) a la derecha (1.0)
      final outTween = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1.0, 0.0),
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: anim.drive(inTween),          // nueva página entra
        child: SlideTransition(
          position: secAnim.drive(outTween),    // página actual sale
          child: child,
        ),
      );
    },
  );
}