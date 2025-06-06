import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/Models/SignUpData.dart';
import 'package:lexi/components/CustomButton.dart';
import 'package:lexi/components/CustomText.dart';
import 'package:lexi/components/TagSelectorController.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpStepFour extends StatefulWidget {
  final SignUpData signUpData;
  final List<Map<String, dynamic>> tagMaps;

  SignUpStepFour({required this.signUpData, required this.tagMaps});

  @override
  _SignUpStepFourState createState() => _SignUpStepFourState();
}

class _SignUpStepFourState extends State<SignUpStepFour> {
  List<Evento> eventos = [];
  final String signUpStepThreeText =
      "Escoge tus 3 principales intereses, esto nos ayudrá a recomendarte eventos que vas a amar.";
  final _formKey = GlobalKey<FormState>();
  late List<String> tags;
  final TagSelectorController _tagController = TagSelectorController();

  @override
  void initState() {
    super.initState();
    tags = widget.tagMaps.map((tag) => tag['name'] as String).toList();
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
        centerTitle: true,
        title: Text('¡Dinos lo que amas!',
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
              SizedBox(height: 20),
              CustomText(
                text: signUpStepThreeText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "SourceSansProNormal",
              ),
              SizedBox(height: 20),
              TagSelector(
                tags: tags,
                controller: _tagController,
                maxSelection: 3,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: "Registrarme",
                onPressed: () async {
                  print("registrando....:");
                  if (_tagController.selectedIndexes.length < 3) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("Por favor selecciona al menos 3 intereses."),
                      ),
                    );
                  } else {
                    try {
                      LoginService loginService =
                          LoginService(baseUrl: Utils.baseUrl);
                      final String birthdateString = DateFormat('yyyy-MM-dd')
                          .format(widget.signUpData.birthDate!);
                      print("birthdateString: $birthdateString");
                      List<int> selectedTagIds = _tagController.selectedIndexes
                          .map((index) => widget.tagMaps[index]['id'] as int)
                          .toList();
                      final response = await loginService.signUp(
                          widget.signUpData.nombre!,
                          widget.signUpData.apellidos!,
                          widget.signUpData.email!,
                          widget.signUpData.genero!,
                          birthdateString,
                          widget.signUpData.password!,
                          widget.signUpData.fotoPerfil ?? null,
                          selectedTagIds);
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
                        prefs.setString('birthdate', data['birthdate']);
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
                        goToHome();
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
              ),
            ],
          ),
        ),
      )),
    );
  }

  Future<void> goToHome() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage(this.eventos)),
    );
  }
}
