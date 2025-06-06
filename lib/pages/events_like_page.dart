import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/LoginService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:http/http.dart' as http;
import 'package:lexi/components/MessageIconBadge.dart';
import 'package:lexi/pages/ChatScreen.dart';
import 'package:lexi/utils/notification_singleton.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsLiked extends StatefulWidget {
  String userProfileId;

  EventsLiked(this.userProfileId);

  @override
  _EventsLiked createState() => _EventsLiked();
}

class _EventsLiked extends State<EventsLiked> {
  List<Evento> likedEvents = new List<Evento>.empty(growable: true);

  @override
  void initState() {
    super.initState();
    NotificationSingleton().setEventsPageActive(true);
    getEventLiked(widget.userProfileId);
  }

  @override
  void dispose() {
    // Al salir, volvemos a desactivar la marca
    NotificationSingleton().setEventsPageActive(false);
    super.dispose();
  }

  Future<void> _openPlaceInGoogleMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'No se pudo abrir la URL: $url';
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
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Eventos que te gustan',
            style: TextStyle(
                color: Color(0xFF1D1B20),
                fontWeight: FontWeight.w700,
                fontSize: 22.0)),
      ),
      body: likedEvents.isEmpty
          ? Center(
              child: Text(
                'Aún no te ha interesado ningún evento!',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: likedEvents.length,
              itemBuilder: (context, index) {
                final event = likedEvents[index];
                final id = event.id.toString();
                final notifier = NotificationSingleton().notifierFor(id);
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: Color(0xFFCAC4D0), // Borde negro
                      width: 1.0, // Grosor del borde
                    ),
                    borderRadius: BorderRadius.circular(
                        12.0), // Bordes redondeados (ajusta a tu gusto)
                  ),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(left: 16, right: 0),
                    title: Text(
                      event.name,
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1D1B20),
                          fontSize: 16.0),
                    ),
                    subtitle: Padding(
                        padding: EdgeInsets.only(top: 6), // como un margin-top
                        child: event.start_date == event.end_date ? Text(
                          '${Utils.convertDateTimeToShortFormat(event.start_date!)} - ${event.place_name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                            fontSize: 14.0,
                          ),
                        ) : Text(
                          '${Utils.convertDateTimeToShortFormat(event.start_date!)} - ${Utils.convertDateTimeToShortFormat(event.end_date!)} - ${event.place_name}',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF1D1B20),
                            fontSize: 14.0,
                          ),
                        )),
                    //leading: Icon(Icons.event, color: Colors.blue),
                    trailing: Row(
                      mainAxisSize:
                          MainAxisSize.min, // Ajusta el tamaño al contenido
                      children: [
                        IconButton(
                          icon: Image.asset(
                            'assets/hidenphone.png',
                            // si tu ícono es blanco o negro puedes cambiarle el color
                            filterQuality: FilterQuality.high,
                          ),
                          onPressed: (1 != 1)
                              ? () async {
                                  if (await canLaunchUrl(
                                      Uri.parse("611466175"))) {
                                    await launchUrl(Uri.parse("611466175"));
                                  } else {
                                    throw 'No se pudo realizar la llamada a 611466175';
                                  }
                                }
                              : null,
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: notifier,
                          builder: (_, count, __) => MessageIconBadge(
                            count: count,
                            offset: Offset(-6, -2), // ajusta según convenga
                            child: IconButton(
                              icon: Image.asset(
                                'assets/message.png',
                                filterQuality: FilterQuality.high,
                              ), // Ícono de "me gusta"
                              onPressed: () async {
                                List<Map<String, String>> chats = [
                                  {
                                    "image":
                                        "https://images.ctfassets.net/denf86kkcx7r/57uYN7JlyDtQ91KvRldrm9/0a0656983993f5e09c4daa0a4fd8f5e6/comment-punir-son-chat-91?fm=webp&w=913",
                                    "name": likedEvents[index].name,
                                    "description":
                                        "Conversaciones sobre eventos interesantes."
                                  }
                                ];
                                NotificationSingleton().clearFor(id);

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                int userId = prefs.getInt('id') ?? 0;
                                LoginService loginService =
                                    LoginService(baseUrl: Utils.baseUrl);
                                String userImageProfileUrl = "";
                                try {
                                  final response =
                                      await loginService.getUserById(userId
                                          .toString()); // Llamada a la función login
                                  print("Response: ${response.body}");
                                  // Verifica el código de estado
                                  if (response.statusCode == 200) {
                                    // Decodificar la respuesta para buscar campo 'error'
                                    final Map<String, dynamic> data =
                                        jsonDecode(response.body);
                                    userImageProfileUrl = data['profileimage'] != null
                                        ? data['profileimage'].trim()
                                        : '';
                                  }
                                } catch (e) {
                                  print(
                                      "Error al obtener la imagen de perfil del usuario: $e");
                                }
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                            chats[0]["name"]!,
                                            event.id.toString(),
                                            widget.userProfileId,
                                            userImageProfileUrl)));
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Image.asset(
                            'assets/location.png',
                            filterQuality: FilterQuality.high,
                          ),
                          onPressed: () {
                            _openPlaceInGoogleMaps(event.url!);
                            // Acción si se desea deshacer el like
                            setState(() {
                              //likedEvents.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void getEventLiked(String userProfileId) async {
    print("getEventLiked" + userProfileId);

    List<Evento> eventos = [];

    try {
      // Construir la URL con el parámetro profileId
      final url =
          Uri.parse(Utils.baseUrl + 'events/liked?profileId=$userProfileId');

      // Realizar la solicitud GET
      final response = await http.get(url);

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200) {
        // Decodificar el cuerpo de la respuesta
        final List<dynamic> responseData = jsonDecode(response.body);

        // Mapear los datos a una lista de objetos Evento
        eventos = responseData
            .map((eventoJson) => Evento.fromJson(eventoJson))
            .toList();
        setState(() {
          likedEvents = eventos;
        });
      } else {
        print(
            'Error al obtener eventos: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error en getEventLiked: $error');
    }
  }
}
