import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/components/CarrouselComponentGif.dart';
import 'package:lexi/components/CustomButton.dart';
import 'package:lexi/components/CustomText.dart';
import 'package:lexi/components/CustomTextFormField.dart';
import 'package:lexi/pages/SplashScreen.dart';
import 'package:lexi/pages/login/LoginPage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ScreenSplashOne extends StatefulWidget {
  @override
  _ScreenSplashOneState createState() => _ScreenSplashOneState();
}

class _ScreenSplashOneState extends State<ScreenSplashOne> {
  static final List<String> gifList = [
    "assets/slider1.gif",
    "assets/slider2.gif",
    "assets/slider3.gif",
  ];

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

  Future<void> fetchEventosAsync() async {
    List<Evento> fetchedEventos = await fetchEventos();
    print("Lista de eventos" + fetchedEventos.toString());
    setState(() {
      eventos = fetchedEventos;
    });
    // 4) Si había un eventId pendiente, lo proceso ahora
    print("eventos totales: ${eventos.length}");
  }

  List<Evento> eventos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            // Esto hace que el contenido suba justo encima del teclado
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            // margen lateral
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
                  child: CarrouselComponentGif(images: gifList),
                ),
                const SizedBox(height: 80),
                CustomButton(
                    text: "Comenzar a Parrandear",
                    onPressed: () {
                      // 3️⃣ Navegamos a tu SplashScreen de Flutter
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    }),
              ],
            )),
      ),
    );
  }
}
