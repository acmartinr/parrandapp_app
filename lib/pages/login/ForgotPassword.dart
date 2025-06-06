import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/components/EmailRestoreGif.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:lexi/pages/login/LoginPage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPassword extends StatefulWidget {
  String email;

  ForgotPassword(this.email);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Image.asset(
              'assets/back.png',
              height: 17,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          centerTitle: true, // ← aquí
          title: Text(
            'Recupera tu contraseña',
            style: TextStyle(
              color: Color(0xFF1D1B20),
              fontFamily: 'SourceSansProBold',
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            // Esto hace que el contenido suba justo encima del teclado
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // margen lateral
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 40),
                      EmailRestoreGif(),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 0),
                        child: Text(
                          'Te enviaremos una contraseña nueva a tu correo electrónico para que puedas acceder a la app. La contraseña puedes cambiarla en cualquier momento en la pantalla de configuración.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'SourceSansProBold',
                            color: Color(0xFF1D1B20),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0, // Quita la elevación
                            textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1D1B20)),
                            backgroundColor: Color(0xFF056A9E), // Fondo verde
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20), // Radio de 20
                            ),
                          ),
                          onPressed: () async {
                            resetPassword(widget.email);
                          },
                          child: Text('Enviar correo de recuperación',
                              style: TextStyle(
                                  fontFamily: 'SourceSansProBold',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> resetPassword(String email) async {
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('El campo correo electrónico no puede estar vacío.')),
      );
      return;
    }
    if (!Utils.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Formato de correo electrónico inválido.')),
      );
      return;
    }
    LoginService loginService = LoginService(baseUrl: Utils.baseUrl);
    try {
      final response = await loginService
          .forgotPassword(email); // Llamada a la función login

      // Verifica el código de estado
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Su contarseña ha sido restablecida, revise su correo')));
        goToLogin();
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hubo un error al recuperar la contraseña')));
      }
    } catch (e) {
      print('Error al realizar el login: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> goToLogin() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
