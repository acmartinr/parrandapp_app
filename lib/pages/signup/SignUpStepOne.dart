import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lexi/Models/SignUpData.dart';
import 'package:lexi/components/CustomButton.dart';
import 'package:lexi/components/CustomText.dart';
import 'package:lexi/components/CustomTextFormField.dart';
import 'package:lexi/pages/signup/SignUpStepTwo.dart';
import 'package:lexi/utils/navigator_utils.dart';
import 'package:lexi/utils/util.dart';
import 'package:image_picker/image_picker.dart';

class SignUpStepOne extends StatefulWidget {
  @override
  _SignUpStepOneState createState() => _SignUpStepOneState();
}

class _SignUpStepOneState extends State<SignUpStepOne> {
  final String signUpStepOneText =
      "Escribe tu nombre, apellidos (opcional) , define tu género y sube una foto de perfil (opcional) para que puedas disfrutar de una mejor experiencia en los chats de eventos.";
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();

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
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text('Información de tu perfil',
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
                                ? AssetImage('assets/profileAddimage.png')
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
                      ),
                      child: IconButton(
                        icon: Image.asset(
                          'assets/addicon.png',
                          height: 30,
                        ),
                        onPressed: _editProfilePicture,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              CustomText(
                text: signUpStepOneText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "SourceSansProNormal",
              ),

              CustomTextFormField(
                labelText: "Nombre",
                controller: _nombreController,
                fontSizeValue: 16,
                fontSizePlaceHolderValue: 20,
              ),
              CustomTextFormField(
                  labelText: "Apellidos (Opcional)",
                  controller: _apellidosController,
                  fontSizeValue: 16,
                  fontSizePlaceHolderValue: 20),
              SizedBox(height: 10),
              Row(
                children: [
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
              SizedBox(height: 10),
              CustomButton(
                  text: "Continuar",
                  onPressed: () async {
                    if (_nombreController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Por favor introduce tu nombre')));
                      return;
                    }

                    final datos = SignUpData(
                      nombre: _nombreController.text.trim(),
                      apellidos: _apellidosController.text.trim(),
                      genero: _generoSeleccionado,
                      fotoPerfil: _pickedImage,
                    );

                    NavigatorUtils.pushSlideLeft(
                      context,
                      SignUpStepTwo(signUpData: datos),
                    );
                  }),
            ],
          ),
        ),
      )),
    );
  }
}
