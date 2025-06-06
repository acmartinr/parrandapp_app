import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:lexi/pages/login/LoginPage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Evento> eventos = [];
  XFile? _pickedImage;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true; // Controla la visibilidad de la contraseña
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _repiteContrasenaController =
      TextEditingController();
  String imageId = "";
  String? _generoSeleccionado = 'h';

  Future<void> _editProfilePicture() async {
    print('Editando foto');
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => LoginPage()),
            );
          },
        ),
        title: Text('Pantalla de registro',
            style: TextStyle(
                color: Color(0xFF1D1B20),
                fontFamily: 'SourceSansProBold',
                fontWeight: FontWeight.w700,
                fontSize: 22.0)),
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 32, right: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 60,
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : (imageId.isEmpty
                                ? AssetImage('assets/profile.png')
                                : NetworkImage(
                                    Utils.baseUrlImage + 'uploads/$imageId'))
                            as ImageProvider,
                  ),
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon:
                            Icon(Icons.add, color: Color(0xFF056A9E), size: 40),
                        onPressed: _editProfilePicture,
                      ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                decoration: InputDecoration(
                  // Si quieres cambiar el tamaño del label:
                  labelText: 'Nombre',
                  labelStyle: TextStyle(
                    fontFamily: 'SourceSansProNormal',
                    fontSize: 16, // aquí pones el tamaño que quieras
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                  ),

                  // O, si lo que usas es hintText en lugar de labelText, personaliza así:
                  // hintText: 'Nombre',
                  // hintStyle: TextStyle(
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.w700,
                  //   color: Color(0xFF1D1B20),
                  // ),
                ),
                style: TextStyle(
                    fontFamily: 'SourceSansProBold',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                controller: _nombreController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: TextStyle(
                    fontFamily: 'SourceSansProBold',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                controller: _apellidosController,
                decoration: InputDecoration(
                  // Si quieres cambiar el tamaño del label:
                  labelText: 'Apellidos',
                  labelStyle: TextStyle(
                    fontFamily: 'SourceSansProNormal',
                    fontSize: 16, // aquí pones el tamaño que quieras
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                  ),

                  // O, si lo que usas es hintText en lugar de labelText, personaliza así:
                  // hintText: 'Nombre',
                  // hintStyle: TextStyle(
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.w700,
                  //   color: Color(0xFF1D1B20),
                  // ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese sus apellidos';
                  }
                  return null;
                },
              ),
              TextFormField(
                style: TextStyle(
                    fontFamily: 'SourceSansProBold',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                controller: _emailController,
                decoration: InputDecoration(
                  // Si quieres cambiar el tamaño del label:
                  labelText: 'Email',
                  labelStyle: TextStyle(
                    fontFamily: 'SourceSansProNormal',
                    fontSize: 16, // aquí pones el tamaño que quieras
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1D1B20),
                  ),

                  // O, si lo que usas es hintText en lugar de labelText, personaliza así:
                  // hintText: 'Nombre',
                  // hintStyle: TextStyle(
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.w700,
                  //   color: Color(0xFF1D1B20),
                  // ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su email';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _edadController,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1B20)),
                      decoration: InputDecoration(
                          labelText: 'Edad',
                          labelStyle: TextStyle(
                            fontFamily: 'SourceSansProNormal',
                            fontSize: 16,
                            // aquí pones el tamaño que quieras
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                          ) // Opcional: mejora la apariencia
                          ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su edad';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D1B20)),
                      value: _generoSeleccionado,
                      items: [
                        DropdownMenuItem(value: 'h', child: Text('Hombre')),
                        DropdownMenuItem(value: 'm', child: Text('Mujer')),
                        DropdownMenuItem(value: 'n', child: Text('No Binario')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _generoSeleccionado = value;
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'Género',
                          labelStyle: TextStyle(
                            fontFamily: 'SourceSansProNormal',
                            fontSize: 16,
                            // aquí pones el tamaño que quieras
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                          ) // Opcional: para un look consistente
                          ),
                    ),
                  ),
                ],
              ),
              TextFormField(
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                controller: _contrasenaController,
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
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    labelText: 'Contraseña',
                    labelStyle: TextStyle(
                      fontFamily: 'SourceSansProNormal',
                      fontSize: 16,
                      // aquí pones el tamaño que quieras
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    ) // Opcional: para un look consistente
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese una contraseña';
                  }
                  return null;
                },
                obscureText: _obscureText,
              ),
              SizedBox(height: 20),
              TextFormField(
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1B20)),
                controller: _repiteContrasenaController,
                decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    labelStyle: TextStyle(
                      fontFamily: 'SourceSansProNormal',
                      fontSize: 16,
                      // aquí pones el tamaño que quieras
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1D1B20),
                    ) // Opcional: para un look consistente
                    ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor repita la contraseña';
                  }
                  if (value != _contrasenaController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
                obscureText: _obscureText,
              ),
              SizedBox(height: 20),
              ElevatedButton(
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
                  if (_formKey.currentState!.validate()) {
                    try {
                      LoginService loginService =
                          LoginService(baseUrl: Utils.baseUrl);
                      final response = await loginService.signUp(
                          _nombreController.text,
                          _apellidosController.text,
                          _emailController.text,
                          _generoSeleccionado!,
                          "",
                          _contrasenaController.text,
                          _pickedImage, []);
                      // Verifica el código de estado
                      if (response.statusCode == 201) {
                        // Si la respuesta es 200, decodificamos el JSON
                        var data = jsonDecode(response.body);

                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        String userProfileId =
                            prefs.getString('userProfileId') ?? "";
                        print("userProfileIdStr: $userProfileId");
                        prefs.setString('userProfileId', data['profileid']);
                        prefs.setString('name', data['name']);
                        prefs.setString('lastname', data['lastname']);
                        prefs.setInt('age', data['age']);
                        prefs.setString('sex', data['sex']);
                        prefs.setString('email', data['email']);
                        prefs.setString('password', data['password']);
                        prefs.setInt('id', data['id']);

                        print("sex: ${data['sex']}");

                        if (data['fcm'] != null) {
                          prefs.setString('fcm', data['fcm']);
                        }

                        // Acceder a los valores del JSON
                        print('profileid: ${data['profileid']}');
                        print('email: ${data['email']}');
                        // Aquí puedes agregar la lógica para enviar los datos
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registro exitoso')));
                        goToHome(_emailController.text);
                        // Puedes guardar estos valores o realizar otras operaciones
                      } else if (response.statusCode == 400) {
                        print('Usuario o contraseña incorrectos');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error al registrar usuario')));
                      print('Error al realizar el login: $e');
                    }
                  }
                },
                child: Text(
                  'Registrar',
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'SourceSansProBold',
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 20, bottom: 40, left: 20, right: 20),
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
                        text: 'Al seleccionar registrar aceptas ',
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
      )),
    );
  }

  Future<void> goToHome(String email) async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage(this.eventos)),
    );
  }
}
