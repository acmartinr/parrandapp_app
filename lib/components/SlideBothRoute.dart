import 'package:flutter/material.dart';

/// Ruta que desplaza la pantalla actual hacia la izquierda
/// y hace entrar la nueva desde la derecha.
class SlideRightToLeftRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideRightToLeftRoute({ required this.page })
      : super(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secAnim) => page,
    transitionsBuilder: (ctx, anim, secAnim, child) {
      final inTween = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final outTween = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(-1, 0),
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: anim.drive(inTween),
        child: SlideTransition(
          position: secAnim.drive(outTween),
          child: child,
        ),
      );
    },
  );
}

/// Ruta que desplaza la pantalla actual hacia la derecha
/// y hace entrar la nueva desde la izquierda.
class SlideLeftToRightRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  SlideLeftToRightRoute({ required this.page })
      : super(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (ctx, anim, secAnim) => page,
    transitionsBuilder: (ctx, anim, secAnim, child) {
      final inTween = Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      final outTween = Tween<Offset>(
        begin: Offset.zero,
        end: const Offset(1, 0),
      ).chain(CurveTween(curve: Curves.easeInOut));

      return SlideTransition(
        position: anim.drive(inTween),
        child: SlideTransition(
          position: secAnim.drive(outTween),
          child: child,
        ),
      );
    },
  );
}