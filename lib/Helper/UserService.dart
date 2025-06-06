import 'dart:convert';

import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;
  final String notificationsRoute = "user/notifications/";
  final String clearNotificationsRoute = "user/notifications/clear";
  final String clearEventNotificationsRoute = "user/notifications/clear/event";

  UserService({required this.baseUrl});

  Future<http.Response> getNotificationsByUserId(String userId) async {
    final url = Uri.parse('$baseUrl$notificationsRoute$userId');
    try {
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'});
      return response;
    } catch (e) {
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> clearNotificationsCount(String userId) async {
    final url = Uri.parse('$baseUrl$clearNotificationsRoute');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{"userId": userId}));
      return response;
    } catch (e) {
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> clearNotificationsForEventCount(
      String userId, String eventId) async {
    final url = Uri.parse('$baseUrl$clearEventNotificationsRoute');
    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{"userId": userId, "eventId": eventId}));
      return response;
    } catch (e) {
      throw Exception('Error al enviar la solicitud: $e');
    }
  }
}
