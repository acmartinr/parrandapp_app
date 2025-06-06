import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/pages/intro/ScreenSplashOne.dart';
import 'package:lexi/utils/notification_singleton.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:lexi/pages/SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lexi/utils/util.dart';
import 'package:http/http.dart' as http;

void main() async {
  // 1️⃣ Capturamos el binding
  final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Arranca tu singleton para que registre todos los listeners
  await NotificationSingleton().init();

  // 2️⃣ Lo pasamos a preserve()
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  runApp(OverlaySupport(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', ''), // Español
        const Locale('en', ''), // Inglés (por si acaso)
        // agrega otros si quieres
      ],
      title: 'Parrandapp',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PreloadPage(),
    );
  }
}

class PreloadPage extends StatefulWidget {
  @override
  _PreloadPageState createState() => _PreloadPageState();
}

class _PreloadPageState extends State<PreloadPage> {
  List<Evento> eventos = [];
  bool _firstTime = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAndContinue();
    });
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

  Future<void> fetchEventosAsync() async {
    List<Evento> fetchedEventos = await fetchEventos();
    print("Lista de eventos" + fetchedEventos.toString());
    setState(() {
      eventos = fetchedEventos;
    });
    // 4) Si había un eventId pendiente, lo proceso ahora
    print("eventos totales: ${eventos.length}");
  }

  Future<void> _preloadAndContinue() async {
    final gifAssets = [
      'assets/welcome.gif',
      'assets/no_events.gif',
      'assets/emailanim.gif',
      'assets/password.gif',
      'assets/birthday.gif',
      'assets/slider1.gif',
      'assets/slider2.gif',
      'assets/slider3.gif',
    ];

    // Precarga cada GIF en el cache
    for (var asset in gifAssets) {
      await precacheImage(AssetImage(asset), context);
    }

    // 2️⃣ Quitamos el splash nativo cuando termine la precarga
    await fetchEventosAsync();
    FlutterNativeSplash.remove();

    if (_firstTime) {
      // 3️⃣ Navegamos a tu SplashScreen de Flutter
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScreenSplashOne()),
      );
    } else {
      // 3️⃣ Navegamos a tu SplashScreen de Flutter
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => SplashScreen(eventos)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retornamos un widget vacío para que no se pinte nada de Flutter
    // mientras el splash nativo sigue activo
    return const SizedBox.shrink();
  }
}
