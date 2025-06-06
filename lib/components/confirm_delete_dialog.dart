import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Confirmación'),
      content: Text('¿Deseas eliminar tu cuenta?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Retorna false si se cancela
          },
          child: Text('Cancelar',style: TextStyle(color: Colors.black)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Retorna true si se confirma
          },
          child: Text('Eliminar' , style: TextStyle(color: Color(0xFFF5363D))),
        ),
      ],
    );
  }
}