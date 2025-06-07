import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/components/SlideBothRoute.dart';
import 'package:lexi/pages/HomePage.dart';
import 'package:lexi/pages/login/LoginPage.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  List<Evento> eventos;

  SplashScreen(this.eventos);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _firstTime = true;
  String? city;
  String? country;
  bool isLoading = true; // Variable para mostrar un indicador de carga
  @override
  void initState() {
    super.initState();
    _checkFirstTime();
    _initLocation();
  }

  Future<void> _getCity() async {
    try {
      print('Getting location...');
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission != LocationPermission.whileInUse &&
            permission != LocationPermission.always) {
          throw Exception('Location permissions are denied');
        }
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocoding to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        setState(() {
          city = placemarks[0].locality; // Get the city name
          country = placemarks[0].country; // Get the country name
        });
      } else {
        throw Exception('No address found');
      }
    } catch (e) {
      setState(() {
        city = 'Error: ${e.toString()}';
      });
      print('Error: ${e.toString()}');
    }
  }

// Helper para crear la ruta animada al LoginPage
  Route _createLoginRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curva suave
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        // Slide desde abajo
        final offsetAnim = Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(curvedAnim);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnim,
            child: child,
          ),
        );
      },
    );
  }

  void _initLocation() async {
    await _getCity();
    print('Getting location...' + city.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', 0.0);
    prefs.setDouble('longitude', 0.0);
    prefs.setString('city', city.toString());
    prefs.setString('country', country.toString());
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenIntro', true);
    bool seen = prefs.getBool('seenIntro') ?? false;
    setState(() {
      _firstTime = !seen;
    });

    if (seen) {
      _completeIntro();
    }
  }

  Future<void> _completeIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenIntro', true);
    if (prefs.getString('userProfileId') != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage(widget.eventos)),
      );
    } else {
      Navigator.of(context).pushReplacement(_createLoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_firstTime) {
      // Primera vez: muestro el carousel
      return IntroCarousel();
    }

    // No es primera vez: programo la navegación a HomePage]
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(widget.eventos)),
      );
    });*/

    // Mientras esperamos el pushReplacement, devuelvo algo neutro,
    // podrías devolver un Scaffold vacío o un SizedBox.shrink()
    return Scaffold(
      body: SizedBox.shrink(),
    );
  }
}

class IntroCarousel extends StatefulWidget {
  @override
  _IntroCarouselState createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage(
                  'assets/splashevent1.png',
                  'Bienvenido a Nuestra App',
                  'Con Parrandapp podrás estar al tanto de todos los eventos que suceden por tu zona.',
                ),
                _buildPage(
                  'assets/splashevent2.png',
                  'Encuentra Eventos',
                  'Explora eventos según tus intereses.',
                ),
                _buildPage(
                  'assets/splashevent3.png',
                  'Mantente al tanto',
                  'Recibe recordatorios de eventos.',
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => _buildDot(index == _currentPage),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_currentPage < 2) {
                    _controller.nextPage(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeIntro();
                  }
                },
                child: Text(_currentPage < 2 ? 'Siguiente' : 'Comenzar'),
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _completeIntro() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('seenIntro', true);
    if (prefs.getString('userProfileId') != null) {
      /*
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomePage()),
      );

       */
    } else {
      Navigator.of(context).pushReplacement(_createLoginRoute());
    }
  }

  Widget _buildPage(String image, String title, String description) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 250),
        SizedBox(height: 24),
        Text(
          title,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 12 : 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.blue : Colors.grey,
      ),
    );
  }

// Helper para crear la ruta animada al LoginPage
  Route _createLoginRoute() {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 600),
      pageBuilder: (context, animation, secondaryAnimation) => LoginPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Curva suave
        final curvedAnim = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        // Slide desde abajo
        final offsetAnim = Tween<Offset>(
          begin: Offset(0, 1),
          end: Offset.zero,
        ).animate(curvedAnim);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnim,
            child: child,
          ),
        );
      },
    );
  }
}
