import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/TagsService.dart';
import 'package:lexi/Models/SignUpData.dart';
import 'package:lexi/components/BirthGif.dart';
import 'package:lexi/components/CustomButton.dart';
import 'package:lexi/components/CustomText.dart';
import 'package:lexi/pages/signup/SignUpStepFour.dart';
import 'package:lexi/utils/navigator_utils.dart';
import 'package:lexi/utils/util.dart';

class SignUpStepThree extends StatefulWidget {
  final SignUpData signUpData;

  SignUpStepThree({required this.signUpData});

  @override
  _SignUpStepThreeState createState() => _SignUpStepThreeState();
}

class _SignUpStepThreeState extends State<SignUpStepThree> {
  DateTime? _selectedDate;
  int? _selectedDay;
  int? _selectedMonth;
  int? _selectedYear;
  final String signUpStepThreeText = "Escribe la fecha de tu cumple.";
  final _formKey = GlobalKey<FormState>();
  String imageId = "";

  void _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(Duration(days: 365 * 18)),
      // Ejemplo: 18 años atrás
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Selecciona tu fecha de nacimiento',
      locale: const Locale('es', ''),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDay = picked.day;
        _selectedMonth = picked.month;
        _selectedYear = picked.year;
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
        title: Text('¿Cuándo cumples?',
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
              Center(
                child: BirthGif(),
              ),
              SizedBox(height: 20),
              CustomText(
                text: signUpStepThreeText,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: "SourceSansProNormal",
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () => _pickDate(context),
                child: Container(
                  width: 297,
                  height: 50,
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _DateSection(
                        width: 60,
                        text: _selectedDay != null
                            ? _selectedDay.toString().padLeft(2, '0')
                            : 'DD',
                      ),
                      SizedBox(width: 8),
                      Text("/",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.black.withOpacity(0.4))),
                      SizedBox(width: 8),
                      _DateSection(
                        width: 60,
                        text: _selectedMonth != null
                            ? _selectedMonth.toString().padLeft(2, '0')
                            : 'MM',
                      ),
                      SizedBox(width: 8),
                      Text("/",
                          style: TextStyle(
                              fontSize: 24,
                              color: Colors.black.withOpacity(0.4))),
                      SizedBox(width: 8),
                      _DateSection(
                        text: _selectedYear != null
                            ? _selectedYear.toString()
                            : 'AAAA',
                        width: 80,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                text: "Continuar",
                onPressed: () async {
                  // Comprobación de mayor de 18 años
                  final hoy = DateTime.now();
                  final fechaMayor18 =
                      DateTime(hoy.year - 18, hoy.month, hoy.day);
                  if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('Por favor introduce una fecha válida')),
                    );
                    return;
                  } else if (_selectedDate!.isAfter(fechaMayor18)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Debes ser mayor de 18 años')),
                    );
                    return;
                  } else {
                    TagsService tagsService =
                        TagsService(baseUrl: Utils.baseUrl);
                    try {
                      final tagsResponse = await tagsService.getAllTags();
                      if (tagsResponse.statusCode == 200) {
                        // Si la respuesta es 200, decodificamos el JSON
                        var data = jsonDecode(tagsResponse.body);
                        List<Map<String, dynamic>> tagMaps = (data as List)
                            .map((e) => e as Map<String, dynamic>)
                            .toList();

                        widget.signUpData.birthDate = _selectedDate!;
                        NavigatorUtils.pushSlideLeft(
                            context,
                            SignUpStepFour(
                                signUpData: widget.signUpData,
                                tagMaps: tagMaps));
                      } else {
                        print("Error al obtener tags");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error interno, intente en un rato')),
                        );
                      }
                    } catch (e) {
                      print("Error al obtener tags: $e");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error interno, intente en un rato')),
                      );
                      return;
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
}

class _DateSection extends StatelessWidget {
  final String text;
  final double width;

  const _DateSection({required this.text, this.width = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          letterSpacing: 2,
          color: Colors.black,
          fontFamily: 'SourceSansProBold',
        ),
      ),
    );
  }
}
