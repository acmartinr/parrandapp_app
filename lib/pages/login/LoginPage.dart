import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/pages/login/PasswordPage.dart';
import 'package:lexi/pages/signup/SignUpStepOne.dart';
import 'package:lexi/utils/navigator_utils.dart';
import 'package:lexi/utils/util.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              child: Image.asset(
                'assets/loginlogo.png',
                height: 150,
                filterQuality: FilterQuality.high,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                'Inicia sesión con tu correo electrónico',
                style: TextStyle(
                  fontFamily: 'SourceSansProBold',
                  color: Color(0xFF1D1B20),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: TextField(
                style: TextStyle(
                  fontFamily: 'SourceSansProBold',
                  color: Color(0xFF1D1B20),
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    fontFamily: '',
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'No tienes cuenta. ',
                    style: TextStyle(
                      fontFamily: 'SourceSansProBold',
                      color: Color(0xFF1D1B20),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      NavigatorUtils.pushSlideLeft(
                          context, SignUpStepOne());
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      // Para que no tenga separación extra
                      minimumSize: Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Regístrate',
                      style: TextStyle(
                        color: Color(0xFF056A9E),
                        fontFamily: 'SourceSansProBold',
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF056A9E),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0, // Quita la elevación
                  textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1B20)),
                  backgroundColor: Color(0xFF24B675), // Fondo verde
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Radio de 20
                  ),
                ),
                onPressed: () async {
                  if (emailController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Debe introducir un email válido')));
                    return;
                  }
                  goToPasswordPage(emailController.text, context);
                },
                child: Text('Continuar',
                    style: TextStyle(
                        fontFamily: 'SourceSansProBold',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 20),
              child: RichText(
                textAlign: TextAlign.start, // Alineado a la izquierda
                text: TextSpan(
                  style: TextStyle(
                    fontFamily: 'SourceSansProNormal',
                    color: Color(0xFF1D1B20),
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                  children: [
                    TextSpan(
                      text: 'Al seleccionar continuar aceptas ',
                    ),
                    TextSpan(
                      text: 'nuestros términos y condiciones.',
                      style: TextStyle(
                        fontFamily: 'SourceSansProNormal',
                        color: Color(0xFF056A9E),
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        decorationColor: Color(0xFF056A9E),
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final Uri url =
                              Uri.parse('https://www.tusitio.com/terminos');
                          if (!await launchUrl(url,
                              mode: LaunchMode.externalApplication)) {
                            throw 'No se pudo abrir el enlace: $url';
                          }
                        },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> goToPasswordPage(String email, BuildContext context) async {
    if (!Utils.isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debe introducir un email válido')));
      return;
    }
    LoginService loginService = LoginService(baseUrl: Utils.baseUrl);
    try {
      final response =
          await loginService.checkEmail(email); // Llamada a la función login

      // Verifica el código de estado
      if (response.statusCode == 200) {
        // Decodificar la respuesta para buscar campo 'error'
        final Map<String, dynamic> data = jsonDecode(response.body);
        String? name = data['name'];
        if (data.containsKey('error')) {
          // Si el código es 404, significa que el email no existe
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  data['error'] ?? 'El email no existe en la base de datos')));
          return;
        }
        Navigator.of(context).push(
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 300),
            pageBuilder: (context, animation, secondaryAnimation) =>
                PasswordPage(email, name ?? ''),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Hubo un error interno, espere unos minutos')));
      }
    } catch (e) {
      print('Hubo un error validando su email : $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
