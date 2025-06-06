import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/FcmTokenService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/components/BadgeIconButton.dart';
import 'package:lexi/components/ButtonsRow.dart';
import 'package:lexi/components/cards_section_alignment.dart';
import 'package:lexi/pages/SettingsPage.dart';
import 'package:lexi/pages/events_like_page.dart';
import 'package:lexi/utils/notification_singleton.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  List<Evento> events;

  HomePage(this.events);

  @override
  _HomePagePageState createState() => _HomePagePageState();
}

class _HomePagePageState extends State<HomePage> {
  bool noMoreCards = false;
  List<Evento> eventosHome = [];
  bool _isModalVisible = false;
  String userProfileIdStr = "";
  late VoidCallback _openedNotifListener;
  List<String> likedEvents = new List<String>.empty(growable: true);
  List<Evento> likedEventsObj = new List<Evento>.empty(growable: true);
  GlobalKey<CardsSectionState> myWidgetKey = GlobalKey<CardsSectionState>();

  Future<List<Evento>> fetchEventos() async {
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
  }

  void getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      String? token = await messaging.getToken();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("fcm", token!);
      print('FCM Token: $token');

      if (token != null) {
        try {
          FcmTokenService fcmTokenService =
              new FcmTokenService(baseUrl: Utils.baseUrl);
          final response =
              await fcmTokenService.update(userProfileIdStr, token);
          if (response.statusCode == 200) {
            print("FCM token updated");
          } else {
            print(
                "Error updating FCM token"); // Error al actualizar el token FCM
          }
        } catch (e) {}
      }
    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    eventosHome = List.from(widget.events);
    requestPermission();
    _loadProfilePreference();
    _openedNotifListener = () {
      final msg = NotificationSingleton().openedNotification.value;
      if (msg != null) {
        final id = msg.data['eventId'] as String;
        _moveEventToFirst(id); // ← aquí llamas al método que mueve la card
      }
    };
    NotificationSingleton()
        .openedNotification
        .addListener(_openedNotifListener);
  }

  @override
  void dispose() {
    // aquí limpias el listener
    NotificationSingleton()
        .openedNotification
        .removeListener(_openedNotifListener);
    super.dispose();
  }

  void _moveEventToFirst(String eventId) {
    if (!mounted) return;

    // 1) Limpia posibles espacios invisibles
    final rawId = eventId.trim();
    print(
        "ID recibido (entre corchetes): [${rawId}] (longitud: ${rawId.length})");

    // 2) Intenta parsear a entero
    final idNum = int.tryParse(rawId);
    if (idNum == null) {
      print("❌ '$rawId' no es un entero válido");
      return;
    }

    // 3) Busca comparando enteros
    print("todos los eventos55: ${eventosHome.map((e) => e.id).toList()}");
    final idx = eventosHome.indexWhere((e) => e.id == idNum);
    print("Buscando evento con ID $idNum, encontrado en índice: $idx");

    if (idx > 0) {
      final newKey = GlobalKey<CardsSectionState>();
      setState(() {
        myWidgetKey = newKey;
        final ev = eventosHome.removeAt(idx);
        eventosHome.insert(0, ev);
      });
      print("✅ Evento $idNum movido al inicio");
    } else if (idx == 0) {
      print("ℹ️ Evento $idNum ya estaba primero");
    } else {
      print("❌ Evento $idNum no existe en la lista");
    }
  }

  void _loadProfilePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userProfileIdStr = prefs.getString('userProfileId') ?? "";
    userProfileIdStr = prefs.getString('userProfileId') ?? "";
  }

  /*
  // Cargar la preferencia de notificaciones desde SharedPreferences
  void _loadProfilePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // prefs.setStringList("likedEvents", []);
      //prefs.setString('userProfileId', "");
      String userProfileId = prefs.getString('userProfileId') ?? "";
      userProfileIdStr = userProfileId;

      print("userProfileIdStr: $userProfileIdStr");
      if (userProfileId.isEmpty) {
        String userProfileId = Utils.generateRandomString(20);
        prefs.setString('userProfileId', userProfileId);
        userProfileIdStr = userProfileId;
        createUserBackend(userProfileId);
      }

      try {
        // eventList = prefs.getStringList('likedEvents') ??
        //      new List<String>.empty(growable: true);
      } catch (e) {
        prefs.setStringList(
            'likedEvents', new List<String>.empty(growable: true));
      }
    });
  }
*/
  Future<void> requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      await FirebaseMessaging.instance.subscribeToTopic('allUsers');
      getToken();
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
      await FirebaseMessaging.instance.subscribeToTopic('allUsers');
      getToken();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _toggleModal() {
    setState(() {
      _isModalVisible = !_isModalVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
            icon: Image.asset(
              'assets/settings.png',
            )),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 0),
              child: ValueListenableBuilder<int>(
                valueListenable: NotificationSingleton().count,
                builder: (context, count, _) {
                  return BadgeIconButton(
                    count: count,
                    assetPath: "assets/like.png",
                    onPressed: () {
                      NotificationSingleton().clear();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                EventsLiked(userProfileIdStr)),
                      );
                    },
                  );
                },
              )),
        ],
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xFFFDFDFD),
              image: DecorationImage(
                  image: AssetImage("assets/fondo.png"),
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high),
            ),
          ),
          Column(
            children: <Widget>[
              CardsSectionAlignment(
                context,
                eventosHome,
                likedEvents,
                key: myWidgetKey,
                onExhausted: (exhausted) {
                  setState(() {
                    noMoreCards = exhausted;
                  });
                },
              ),
              !(noMoreCards || eventosHome.isEmpty)
                  ? ButtonsRow(
                      noMoreCards: (noMoreCards || eventosHome.isEmpty),
                      onNotLike: () {
                        myWidgetKey.currentState?.notLikeEventFromButton();
                      },
                      onDoLike: () {
                        myWidgetKey.currentState?.likeEventFromButton();
                      },
                      onShare: () {
                        myWidgetKey.currentState?.shareEvent();
                      },
                    )
                  : Container(),
            ],
          ),
          if (_isModalVisible)
            GestureDetector(
              onTap: _toggleModal,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: AnimatedScale(
                    scale: _isModalVisible ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: 300,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Evento Recomendado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Image.asset('assets/eventimg.jpg',
                              fit: BoxFit.contain),
                          SizedBox(height: 10),
                          Text(
                            'Creemos que este evento te puede interesar!',
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20),
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 48.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                FloatingActionButton(
                                  heroTag: "btnNotLike",
                                  onPressed: () {
                                    myWidgetKey.currentState!
                                        .notLikeEventFromButton();
                                  },
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/notlike.png',
                                    // Path to your PNG image
                                    width: 24, // Adjust size as needed
                                    height: 24, // Adjust size as needed
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 8.0)),
                                FloatingActionButton(
                                  heroTag: "btnLike",
                                  onPressed: () {
                                    myWidgetKey.currentState!
                                        .likeEventFromButton();
                                  },
                                  backgroundColor: Colors.white,
                                  child: Image.asset(
                                    'assets/dolike.png',
                                    // Path to your PNG image
                                    width: 24, // Adjust size as needed
                                    height: 24, // Adjust size as needed
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: noMoreCards || eventosHome.isEmpty
          ? ButtonsRow(
              noMoreCards: (noMoreCards || eventosHome.isEmpty),
              onNotLike: () {
                myWidgetKey.currentState?.notLikeEventFromButton();
              },
              onDoLike: () {
                myWidgetKey.currentState?.likeEventFromButton();
              },
              onShare: () {
                myWidgetKey.currentState?.shareEvent();
              },
            )
          : null,
    );
  }
}
