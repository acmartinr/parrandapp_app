import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/components/WelcomeGif.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:lexi/pages/login/ForgotPassword.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PasswordPage extends StatefulWidget {
  String email;
  String name;

  PasswordPage(this.email, this.name);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  List<Evento> eventos = [];

  Future<void> fetchEventosAsync() async {
    List<Evento> fetchedEventos = await fetchEventos();
    print("Lista de eventos" + fetchedEventos.toString());
    setState(() {
      eventos = fetchedEventos;
    });
    // 4) Si había un eventId pendiente, lo proceso ahora
    print("eventos totales: ${eventos.length}");
  }

  Future<List<Evento>> fetchEventos() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String userProfileId = prefs.getString('userProfileId') ?? "";
      print("userProfileId: $userProfileId");
      final response = await http
          .get(Uri.parse(Utils.baseUrl + 'events?profileId=$userProfileId'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        print("Eventos en Gijon: " + jsonResponse.toString());
        return jsonResponse.map((event) => Evento.fromJson(event)).toList();
      } else {
        print("Error al cargar eventos" + response.body);
        throw Exception('Failed to load events');
      }
    } catch (e) {
      print("Error al obtener eventos: $e");
    }
    return [];
  }

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
            '¡Bienvenido!',
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
                // Aquí tu GIF, pegado al top de la SafeArea
                WelcomeGif(),

                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                  child: Text(
                    '¡Nos alegra que estés de vuelta ' +
                        widget.name.trim() +
                        '! Introduce la contraseña de tu usuario para que puedas acceder a la app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'SourceSansProBold',
                      color: Color(0xFF1D1B20),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // resto de campos...
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: TextField(
                    controller: passwordController,
                    style: TextStyle(
                        color: Color(0xFF1D1B20),
                        fontFamily: 'SourceSansProBold',
                        fontWeight: FontWeight.w700,
                        fontSize: 20.0),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        icon: _obscureText
                            ? Image.asset(
                                "assets/eyepasshidde.png",
                                height: 25,
                              ) // Imagen para contraseña oculta
                            : Image.asset(
                                "assets/eyepass.png",
                                height: 25,
                              ),
                        // Imagen para contraseña visible
                        onPressed: () {
                          setState(() {
                            print("Icon pressed: $_obscureText");
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      labelText: 'Contraseña',
                      labelStyle: TextStyle(
                        color: Color(0xFF1D1B20),
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        fontFamily: 'SourceSansProNormal',
                      ),
                    ),
                    obscureText: _obscureText,
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
                      LoginService loginService =
                          LoginService(baseUrl: Utils.baseUrl);
                      try {
                        final response = await loginService.login(
                            widget.email,
                            passwordController
                                .text); // Llamada a la función login

                        // Verifica el código de estado
                        if (response.statusCode == 200) {
                          // Si la respuesta es 200, decodificamos el JSON
                          var data = jsonDecode(response.body);
                          // Acceder a los valores del JSON
                          print('email: ${data['email']}');
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          String userProfileId =
                              prefs.getString('userProfileId') ?? "";
                          print("userProfileIdStr: $userProfileId");
                          prefs.setString('userProfileId', data['profileid']);
                          prefs.setString('name', data['name']);
                          prefs.setString('lastname', data['lastname']);
                          prefs.setString('sex', data['sex']);
                          prefs.setString('email', data['email']);
                          prefs.setString('password', data['password']);
                          prefs.setInt('id', data['id']);

                          print("sex: ${data['sex']}");

                          if (data['fcm'] != null) {
                            prefs.setString('fcm', data['fcm']);
                          }

                          await fetchEventosAsync();

                          goToHome(widget.email);
                          // Puedes guardar estos valores o realizar otras operaciones
                        } else if (response.statusCode == 400) {
                          print('Usuario o contraseña incorrectos');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content:
                                  Text('Usuario o contraseña incorrectos')));
                        }
                      } catch (e) {
                        print('Error al realizar el login: $e');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Error al realizar el login')));
                      }
                    },
                    child: Text('Continuar',
                        style: TextStyle(
                            fontFamily: 'SourceSansProBold',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ),
                ),
                TextButton(
                  onPressed: () => goToForgotPassword(widget.email),
                  child: const Text(
                    '¿Olvidaste la contraseña?',
                    style: TextStyle(
                        fontFamily: 'SourceSansProNormal',
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF056A9E),
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF056A9E)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Future<void> goToHome(String email) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage(this.eventos)),
    );
  }

  Future<void> goToForgotPassword(String email) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => ForgotPassword(email)),
    );
  }
}
