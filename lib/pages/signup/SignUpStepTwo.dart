import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/Models/SignUpData.dart';
import 'package:lexi/components/CustomButton.dart';
import 'package:lexi/components/CustomText.dart';
import 'package:lexi/components/CustomTextFormField.dart';
import 'package:lexi/components/PasswordGif.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lexi/pages/signup/SignUpStepThree.dart';
import 'package:lexi/utils/navigator_utils.dart';
import 'package:lexi/utils/util.dart';

class SignUpStepTwo extends StatefulWidget {
  final SignUpData signUpData;

  SignUpStepTwo({required this.signUpData});

  @override
  _SignUpStepTwoState createState() => _SignUpStepTwoState();
}

class _SignUpStepTwoState extends State<SignUpStepTwo> {
  final String signUpStepTwoText = "Escribe tu correo y crea una contraseña.";
  bool _obscureText = true; // Controla la visibilidad de la contraseña
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _repiteContrasenaController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String imageId = "";

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
        centerTitle: true,
        title: Text('Crea tu contraseña',
            style: TextStyle(
                color: Color(0xFF1D1B20),
                fontFamily: 'SourceSansProBold',
                fontWeight: FontWeight.w700,
                fontSize: 22.0)),
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 0, left: 32, right: 32),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              PasswordGif(),
              CustomText(
                text: signUpStepTwoText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "SourceSansProNormal",
              ),

              CustomTextFormField(
                labelText: "Correo",
                controller: _emailController,
                fontSizeValue: 16,
                fontSizePlaceHolderValue: 20,
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
              SizedBox(height: 10),
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
              CustomButton(
                  text: "Continuar",
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Por favor introduce un email válido')));
                      return;
                    }
                    LoginService loginService =
                        LoginService(baseUrl: Utils.baseUrl);
                    try {
                      final response = await loginService.checkEmail(
                          _emailController.text
                              .trim()); // Llamada a la función login

                      // Verifica el código de estado
                      if (response.statusCode == 200) {
                        // Decodificar la respuesta para buscar campo 'error'
                        final Map<String, dynamic> data =
                            jsonDecode(response.body);
                        String? name = data['name'];
                        if (data.containsKey('error')) {
                          // Si el código es 404, significa que el email no existe
                          if (_formKey.currentState!.validate()) {
                            widget.signUpData.email =
                                _emailController.text.trim();
                            widget.signUpData.password =
                                _contrasenaController.text.trim();

                            NavigatorUtils.pushSlideLeft(context,
                                SignUpStepThree(signUpData: widget.signUpData));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Por favor llene todos loc campos requeridos')));
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Ya existe un usuario registrado con este email')));
                        }
                      } else if (response.statusCode == 400) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Hubo un error interno, espere unos minutos')));
                      }
                    } catch (e) {
                      print('Hubo un error validando su email : $e');
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  }),
            ],
          ),
        ),
      )),
    );
  }
}
