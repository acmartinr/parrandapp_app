// lib/notification_singleton.dart
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/UserService.dart';
import 'package:lexi/Models/NotificationConfig.dart';
import 'package:lexi/utils/util.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSingleton {
  // Singleton
  NotificationSingleton._();

  bool _isOnEventsPage = false;
  bool _isOnMessagePage = false;
  bool _isOnLikedEventsPage = false;
  String? _currentEventId;

  static final NotificationSingleton _instance = NotificationSingleton._();

  factory NotificationSingleton() => _instance;

  // Claves para SharedPreferences
  static const String _kGlobalCountKey = 'notif_count_global';
  static const String _kEventCountKeyPrefix = 'notif_count_event_';

  // Mapa de contadores “observables” por eventId
  final Map<String, ValueNotifier<int>> _counts = {};
  final ValueNotifier<RemoteMessage?> openedNotification = ValueNotifier(null);
  var notificationConfig = NotificationConfig(
    total: 0,
    eventos: [],
  );

  void setCurrentEvent(String? eventId) {
    _currentEventId = eventId;
  }

  // Para saber si la notificación que llega es de esta pantalla:
  bool _isNotificationForCurrentEvent(RemoteMessage msg) {
    final eventIdFromMsg = msg.data['eventId'] as String?;
    return eventIdFromMsg != null && eventIdFromMsg == _currentEventId;
  }

  // Prefs cached después de init()
  late SharedPreferences _prefs;

  late UserService userService;

  // El contador “observable”
  final ValueNotifier<int> count = ValueNotifier<int>(0);

  // 3) Inicialización FCM + carga de prefs
  Future<void> init() async {
    // a) Carga SharedPreferences y valor inicial
    _prefs = await SharedPreferences.getInstance();
    userService = UserService(baseUrl: Utils.baseUrl);

    final response = await userService
        .getNotificationsByUserId(_prefs.getInt("id").toString());
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      notificationConfig = NotificationConfig.fromJson(data);
      if (data.containsKey('error')) {
        print('Error: ${data['error']}');
        return;
      }
      print('Notificaciones:' + notificationConfig.total.toString());
      count.value = data['total'] ?? 0;
    } else {
      print('Error al obtener las notificaciones: ${response.statusCode}');
    }
    //count.value = _prefs.getInt(_kGlobalCountKey) ?? 0;

    // b) Registra el handler de background
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    // c) Pide permisos (iOS)
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Permisos FCM: ${settings.authorizationStatus}');

    // d) Token (opcional)
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint('FCM Token: $token');

    // e) Listener cuando la app está en foreground
    FirebaseMessaging.onMessage.listen(_onMessage);

    // f) Cuando el usuario abre una notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

    // g) Si la app estaba totalmente cerrada y la abres desde notif
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) _onMessageOpened(initial);
  }

  void _onMessageOpened(RemoteMessage msg) {
    final RemoteNotification? notif = msg.notification;
    debugPrint('🔔 Abrió notif con data 22: ${msg.data}');
    openedNotification.value = msg; // <— disparamos aquí
    // navegar a pantalla concreta si quieres
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage msg) async {
    // ¡OJO! Aquí no debes usar contexto ni UI
    NotificationSingleton()._incrementSilently();
    final eventId = msg.data['eventId'];
    if (eventId != null) NotificationSingleton().incrementFor(eventId);
  }

  void _onMessage(RemoteMessage msg) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userProfileId = prefs.getString('userProfileId') ??
        ""; // 1) Saca el notification en una variable local nullable
    final RemoteNotification? notif = msg.notification;
    print('ProfileId usuario' + userProfileId);
    print("evento: ${msg.data['eventId']}");
    final profileSent = msg.data['senderId'];
    print('id profile envio: $profileSent');
    print('Nueva notificación22: ${notif?.title}, ${notif?.body}');
    // Esto es para evitar errores si msg.notification es null
    print("_isOnMessagePage" + _isOnMessagePage.toString());
    if (notif != null && profileSent != userProfileId && !_isOnMessagePage) {
      // Muestras la notificación in-app
      showSimpleNotification(
        Text(notif.title ?? '¡Notificación!'),
        // si title es null pones un fallback
        subtitle: Text(notif.body ?? ''),
        // idem para body
        background: Colors.blueAccent,
        position: NotificationPosition.top,
        slideDismiss: true,
        duration: Duration(seconds: 4),
      );
    }

    // 2) Comprueba primero que no sea null
    if (notif != null && !_isOnEventsPage) {
      // Incrementas tu contador
      increment();
    }
    // 1) Si no estoy en la misma pantalla de evento, aumento el badage de ese evento
    if (notif != null &&
        profileSent != userProfileId &&
        !_isNotificationForCurrentEvent(msg)) {
      // Resto de tu lógica por evento...
      final eventId = msg.data['eventId'];
      if (eventId != null) incrementFor(eventId);
    }
  }

  /// Incrementa el contador y persiste en SharedPreferences
  void increment() {
    count.value = count.value + 1;
    _saveCount();
  }

  /// Para background handler (sin reconstruir UI), también persiste
  void _incrementSilently() {
    count.value = count.value + 1;
    _saveCount();
  }

  /// Limpia el contador y elimina el valor de SharedPreferences
  Future<void> clear() async {
    count.value = 0;
    final response = await userService
        .clearNotificationsCount(_prefs.getInt("id").toString());
    if (response.statusCode == 200) {
    } else {
      print('Error al limpiar las notificaciones: ${response.statusCode}');
    }
  }

  /// Guarda el valor actual de [count] en SharedPreferences
  Future<void> _saveCount() async {
    await _prefs.setInt(_kGlobalCountKey, count.value);
  }

  /// Devuelve (o crea) el ValueNotifier para un [eventId]
  ValueNotifier<int> notifierFor(String eventId) {
    if (!_counts.containsKey(eventId)) {
      final ev = notificationConfig.eventos.firstWhere(
        (e) => e.id == eventId,
        orElse: () => Evento(id: eventId, contador: 0),
      );
      _counts[eventId] = ValueNotifier<int>(ev.contador);
    }
    return _counts[eventId]!;
  }

  /// Incrementa y persiste contador para un [eventId]
  void incrementFor(String eventId) {
    final notifier = notifierFor(eventId);
    notifier.value++;
    _prefs.setInt('$_kEventCountKeyPrefix\_$eventId', notifier.value);
  }

  Future<void> clearFor(String eventId) async {
    print('Limpiando notificaciones para el evento: $eventId');

    final notifier = notifierFor(eventId);

    notifier.value = 0;

    final response = await userService.clearNotificationsForEventCount(
      _prefs.getInt("id").toString(),
      eventId,
    );
    if (response.statusCode != 200) {
      print('Error al limpiar las notificaciones: ${response.statusCode}');
    }
  }

  /// Llama esto desde tu página de eventos
  void setEventsPageActive(bool active) {
    _isOnEventsPage = active;
  }

  void setMessagePageActive(bool active) {
    print("setMessagePageActive: $active");
    _isOnMessagePage = active;
  }

  /// Llama esto desde tu página de chat
  void setLikedEventsChatActive(bool active) {
    _isOnLikedEventsPage = active;
  }
}
