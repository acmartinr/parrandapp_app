import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Modelo principal
class NotificationConfig {
  int total;
  List<Evento> eventos;

  NotificationConfig({
    required this.total,
    required this.eventos,
  });

  factory NotificationConfig.fromJson(Map<String, dynamic> json) {
    return NotificationConfig(
      total: json['total'] as int,
      eventos: (json['eventos'] as List<dynamic>)
          .map((e) => Evento.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'eventos': eventos.map((e) => e.toJson()).toList(),
    };
  }

  /// Devuelve true si existe un evento con el id dado
  bool hasEvent(String id) => eventos.any((e) => e.id == id);
}

// Submodelo de cada evento
class Evento {
  String id;
  int contador;

  Evento({
    required this.id,
    required this.contador,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] as String,
      contador: json['contador'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contador': contador,
    };
  }
}

// Clase para gestionar almacenamiento local
class ConfigStorage {
  static const _key = 'notification_config';

  // Guarda la configuración en SharedPreferences
  static Future<void> saveConfig(NotificationConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(config.toJson());
    await prefs.setString(_key, jsonString);
  }

  // Recupera la configuración; si no existe, devuelve null
  static Future<NotificationConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return NotificationConfig.fromJson(jsonMap);
  }
}
