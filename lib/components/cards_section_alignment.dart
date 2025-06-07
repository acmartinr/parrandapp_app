import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lexi/Helper/EventService.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/components/NoEventsCard.dart';
import 'package:lexi/components/NoEventsGif.dart';
import 'package:lexi/components/action_card_circle.dart';
import 'package:lexi/utils/notification_singleton.dart';
import 'package:lexi/utils/util.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile_card_alignment.dart';
import 'dart:math';
import 'package:http/http.dart' as http;

List<Alignment> cardsAlign = [
  Alignment(0.0, 1.0),
  Alignment(0.0, 0.8),
  Alignment(0.0, 0.0)
];
List<Size> cardsSize = List.filled(3, Size.zero, growable: false);

class CardsSectionAlignment extends StatefulWidget {
  final List<Evento> eventos;
  final List<String> likedEvents;
  final ValueChanged<bool> onExhausted; // ← callback

  CardsSectionAlignment(BuildContext context, this.eventos, this.likedEvents,
      {Key? key, required this.onExhausted})
      : super(key: key) {
    cardsSize[0] = Size(MediaQuery.of(context).size.width * 0.9,
        MediaQuery.of(context).size.height * 0.6);
    cardsSize[1] = Size(MediaQuery.of(context).size.width * 0.85,
        MediaQuery.of(context).size.height * 0.55);
    cardsSize[2] = Size(MediaQuery.of(context).size.width * 0.8,
        MediaQuery.of(context).size.height * 0.5);
  }

  @override
  CardsSectionState createState() => CardsSectionState();
}

class CardsSectionState extends State<CardsSectionAlignment>
    with SingleTickerProviderStateMixin {
  bool skipServiceCall = false;
  bool showYesIndicator = false;
  bool showNoIndicator = false;
  bool likeEvent = false;
  double swipeThreshold = 0.3; // Umbral para mostrar los indicadores
  int cardsCounter = 0;
  int starterCounter = 0;
  List<ProfileCardAlignment> cards = List.empty(growable: true);
  late AnimationController _controller;
  bool noMoreCards = false; // Variable para indicar si no hay más tarjetas

  final Alignment defaultFrontCardAlign = Alignment(0.0, 0.0);
  late Alignment frontCardAlign;
  double frontCardRot = 0.0;

  @override
  void initState() {
    super.initState();
    print("cantidad de eventos: " + widget.eventos.length.toString());

    // Init cards
    for (cardsCounter = 0; cardsCounter < 3; cardsCounter++) {
      if (cardsCounter < widget.eventos.length) {
        starterCounter = cardsCounter + 1;
        cards.add(ProfileCardAlignment(cardsCounter,
            evento: widget.eventos[cardsCounter]));
      }
    }

    frontCardAlign = cardsAlign[2];

    // Init the animation controller
    _controller =
        AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {
          showYesIndicator = false;
          showNoIndicator = false;
        }));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) changeCardsOrder();
    });
  }

  OverlayEntry createOverlayEntry(String text, Color color, bool showYes) {
    return OverlayEntry(
      builder: (context) => Positioned(
          top: MediaQuery.of(context).size.height / 2 -
              60, // Centrar verticalmente
          left: MediaQuery.of(context).size.width / 2 -
              60, // Centrar horizontalmente
          child: ActionCardCircle(show: showYes, text: text, color: color)),
    );
  }

  Future<void> _incrementNotificationOnce() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('firstLikeDone') ?? false;
    if (!done) {
      NotificationSingleton().increment();
      await prefs.setBool('firstLikeDone', true);
    }
  }

  void shareEvent() {
    String eventName =
        widget.eventos.elementAt(cardsCounter - 3).name.toString();
    String placeName =
        widget.eventos.elementAt(cardsCounter - 3).place_name.toString();
    String date =
        widget.eventos.elementAt(cardsCounter - 3).start_date.toString();

    Share.share(
        "¡Hola! Te recomiendo este evento que encontré en la app de Parrandapp: " +
            eventName +
            " en " +
            placeName +
            " el " +
            Utils.convertDateTimeToShortFormat(date! ?? 'Por confirmar') +
            ". ¡No te lo pierdas!");
  }

  void likeEventFromButton() async {
    skipServiceCall = true; // <— marca que ya lo has llamado
    print("likeEventFromButton");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userBackId = prefs.getInt('id')!;
    String eventId = widget.eventos.elementAt(cardsCounter - 3).id.toString();
    String startDate =
        widget.eventos.elementAt(cardsCounter - 3).start_date.toString();
    String endDate =
        widget.eventos.elementAt(cardsCounter - 3).end_date.toString();
    bool multipleEvents =
        startDate != endDate && startDate.isNotEmpty && endDate.isNotEmpty;
    bool likeOk = await callLikeEvent(
        userBackId.toString(), eventId, true, multipleEvents);
    if (likeOk) {
      _incrementNotificationOnce();
      OverlayEntry overlayEntry =
          createOverlayEntry("¡Voy!", Color(0xFF24B675), true); // Crear overlay

      // Insertar el overlay en la pantalla
      Overlay.of(context)?.insert(overlayEntry);

      setState(() {
        frontCardAlign =
            Alignment(3.0, 0.0); // Simula el deslizamiento hacia la derecha
        showYesIndicator = true; // Muestra el indicador "Voy"
        showNoIndicator = false; // Asegura que el indicador "No" esté oculto
      });

      // Eliminar el overlay después de un tiempo
      Future.delayed(Duration(milliseconds: 500), () {
        overlayEntry.remove(); // Remover el overlay
        setState(() {
          showYesIndicator = false; // Ocultar el indicador "Voy"
        });
      });

      animateCards(); // Inicia la animación
    }
  }

  void notLikeEventFromButton() async {
    skipServiceCall = true; // <— idem
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userBackId = prefs.getInt('id')!;
    String eventId = widget.eventos.elementAt(cardsCounter - 3).id.toString();
    String startDate =
        widget.eventos.elementAt(cardsCounter - 3).start_date.toString();
    String endDate =
        widget.eventos.elementAt(cardsCounter - 3).end_date.toString();
    bool multipleEvents =
        startDate != endDate && startDate.isNotEmpty && endDate.isNotEmpty;
    bool likeOk = await callLikeEvent(
        userBackId.toString(), eventId, false, multipleEvents);

    if (likeOk) {
      OverlayEntry overlayEntry =
          createOverlayEntry("Nop", Color(0xFFF5363D), true); // Crear overlay

      // Insertar el overlay en la pantalla
      Overlay.of(context)?.insert(overlayEntry);

      setState(() {
        frontCardAlign =
            Alignment(-3.0, 0.0); // Simula el deslizamiento hacia la derecha
        showYesIndicator = false; // Muestra el indicador "Voy"
        showNoIndicator = true; // Asegura que el indicador "No" esté oculto
      });

      // Eliminar el overlay después de un tiempo
      Future.delayed(Duration(milliseconds: 500), () {
        overlayEntry.remove(); // Remover el overlay
        setState(() {
          showYesIndicator = false; // Ocultar el indicador "Voy"
        });
      });

      animateCards(); // Inicia la animación
    }
  }

  Future<bool> callLikeEvent(
      String userBackId, String eventId, bool like, bool multipleEvents) async {
    print("EventId" + eventId);
    print("UserId" + userBackId);

    try {
      // Preparar la URL y el cuerpo de la solicitud
      final url = Uri.parse(Utils.baseUrl + 'events/like');
      final body = jsonEncode({
        "userId": userBackId,
        "eventId": eventId,
        "like": like, // "t" para like
        "multipleEvents": multipleEvents,
      });

      // Realizar la solicitud POST
      final response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: body,
      );

      // Verificar si la respuesta es exitosa
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Evento marcado como like exitosamente.");
        return true;
      } else {
        print(
            "Error al marcar el evento como like: ${response.statusCode} - ${response.reasonPhrase}");
        return false;
      }
    } catch (error) {
      print("Error en callLikeEvent: $error");
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return noMoreCards || cards.isEmpty
        ? NoEventsCard()
        : Expanded(
            child: Stack(
              children: <Widget>[
                if (cards.length > 2) backCard(),
                if (cards.length > 1) middleCard(),
                if (cards.isNotEmpty) frontCard(),

                // Indicador de "Sí"
                Positioned(
                  top: 100,
                  right: 11,
                  child: AnimatedOpacity(
                    opacity: showYesIndicator ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: ActionCardCircle(
                        show: true, // <-- siempre true, controlas con el fade
                        text: "¡Voy!",
                        color: Color(0xFF24B675)),
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 10,
                  child: AnimatedOpacity(
                    opacity: showNoIndicator ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    child: ActionCardCircle(
                        show: true, // <-- siempre true
                        text: "Nop",
                        color: Color(0xFFF5363D)),
                  ),
                ),

                // Prevent swiping if the cards are animating
                _controller.status != AnimationStatus.forward
                    ? SizedBox.expand(
                        child: GestureDetector(
                          onPanUpdate: (DragUpdateDetails details) {
                            setState(() {
                              final screenWidth =
                                  MediaQuery.of(context).size.width;
                              final screenHeight =
                                  MediaQuery.of(context).size.height;

                              // Factores ajustados
                              const double horizontalFactor =
                                  40.0; // más “jalada” lateral
                              const double verticalFactor =
                                  10.0; // muy suave arriba/abajo

                              // Límites de alineación
                              const double maxX =
                                  2.0; // permitimos hasta ±2.0 en X
                              const double maxY = 0.8; // limitamos Y a ±0.8

                              // Nuevo cálculo de posición
                              double newX = frontCardAlign.x +
                                  horizontalFactor *
                                      details.delta.dx /
                                      screenWidth;
                              double newY = frontCardAlign.y +
                                  verticalFactor *
                                      details.delta.dy /
                                      screenHeight;

                              // Clamp con nuevos límites
                              newX = newX.clamp(-maxX, maxX);
                              newY = newY.clamp(-maxY, maxY);

                              frontCardAlign = Alignment(newX, newY);
                              frontCardRot = newX;

                              // Indicadores de “sí” / “no”
                              if (newX > swipeThreshold) {
                                showYesIndicator = true;
                                showNoIndicator = false;
                                likeEvent = true;
                              } else if (newX < -swipeThreshold) {
                                showYesIndicator = false;
                                showNoIndicator = true;
                                likeEvent = false;
                              } else {
                                showYesIndicator = false;
                                showNoIndicator = false;
                                likeEvent = false;
                              }
                            });
                          },
                          onPanEnd: (_) {
                            if (frontCardAlign.x.abs() > swipeThreshold) {
                              animateCards();
                            } else {
                              setState(() {
                                frontCardAlign = defaultFrontCardAlign;
                                frontCardRot = 0.0;
                                showYesIndicator = false;
                                showNoIndicator = false;
                              });
                            }
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          );
  }

  Widget backCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.backCardAlignmentAnim(_controller).value
          : cardsAlign[0],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.backCardSizeAnim(_controller).value
              : cardsSize[2],
          child: cards.length > 2 ? cards[2] : Container()),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_controller).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_controller).value
              : cardsSize[1],
          child: cards.length > 1 ? cards[1] : Container()),
    );
  }

  Widget frontCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.frontCardDisappearAlignmentAnim(
                  _controller, frontCardAlign)
              .value
          : frontCardAlign,
      child: Transform.rotate(
        angle: (pi / 180.0) * frontCardRot,
        child: SizedBox.fromSize(
            size: cardsSize[0],
            child: cards.isNotEmpty ? cards[0] : Container()),
      ),
    );
  }

  Widget buildIndicator(Color color, String text) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      width: 120,
      height: 120,
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 32),
        ),
      ),
    );
  }

  Widget buildCard(String evento) {
    return Card(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: Text(
            evento,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  void changeCardsOrder() {
    // 1. Guarda la tarjeta y sus datos antes de moverla
    final int cardIndex = cardsCounter - 3;
    final ProfileCardAlignment swipedCard = cards[0]; // Tarjeta al frente

    // Guarda los datos para el posible rollback
    int previousCardsCounter = cardsCounter;
    bool previousNoMoreCards = noMoreCards;

    // 2. Mueve las tarjetas y actualiza la UI
    setState(() {
      if (cardsCounter >= widget.eventos.length + 2) {
        noMoreCards = true;
        widget.onExhausted(true);
      } else {
        var temp = cards[0];
        if (starterCounter > 1) {
          cards[0] = cards[1];
        }
        if (starterCounter > 2) {
          cards[1] = cards[2];
        }

        cards[starterCounter - 1] = temp;

        if (cardsCounter < widget.eventos.length) {
          cards[2] = ProfileCardAlignment(cardsCounter,
              evento: widget.eventos[cardsCounter]);
        }

        cardsCounter++;
        frontCardAlign = defaultFrontCardAlign;
        frontCardRot = 0.0;
      }
    });

    // 3. Lanza el servicio en background (NO bloquea la UI)
    _likeEventIfNeeded(
        cardIndex, swipedCard, previousCardsCounter, previousNoMoreCards);
  }

// Este método es asíncrono, hace el "rollback" visual si falla la petición
  Future<void> _likeEventIfNeeded(
      int cardIndex,
      ProfileCardAlignment swipedCard,
      int previousCardsCounter,
      bool previousNoMoreCards) async {
    if (!skipServiceCall) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String idStr = prefs.getInt('id').toString();
      String eventId = widget.eventos.elementAt(cardIndex).id.toString();
      String startDate =
          widget.eventos.elementAt(cardsCounter - 3).start_date.toString();
      String endDate =
          widget.eventos.elementAt(cardsCounter - 3).end_date.toString();
      bool multipleEvents =
          startDate != endDate && startDate.isNotEmpty && endDate.isNotEmpty;

      EventService eventService = EventService(baseUrl: Utils.baseUrl);

      try {
        final response = await eventService.likeEvent(
            idStr, eventId, likeEvent, multipleEvents);
        print('Response status: ${response.statusCode}, likeEvent: $likeEvent');
        if (response.statusCode == 200 && likeEvent) {
          _incrementNotificationOnce();
        } else if (response.statusCode == 400) {
          _rollbackCard(swipedCard, previousCardsCounter, previousNoMoreCards);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error interno')));
        }
      } catch (e) {
        _rollbackCard(swipedCard, previousCardsCounter, previousNoMoreCards);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error interno')));
      }
    } else {
      skipServiceCall = false;
    }
  }

// Este método repone la tarjeta en caso de error
  void _rollbackCard(
      ProfileCardAlignment card, int prevCounter, bool prevNoMoreCards) {
    setState(() {
      cards.insert(0, card); // Repone la tarjeta al frente
      cardsCounter = prevCounter;
      noMoreCards = prevNoMoreCards;
      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
    });
  }

  void animateCards() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size?> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(
      AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size?> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0]).animate(
        CurvedAnimation(
            parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(
      AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
            begin: beginAlign,
            end: Alignment(
                beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0,
                0.0))
        .animate(CurvedAnimation(
            parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }
}
