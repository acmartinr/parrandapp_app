import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl;
  final String sendNotificationRoute = "notifications/new-message";

  NotificationService({required this.baseUrl});

  Future<http.Response> sendMessage(String text,String groupName, String eventId) async {
    final url = Uri.parse('$baseUrl$sendNotificationRoute');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:
        jsonEncode(<String, String>{
          "text": text,
          "groupName": groupName,
          "eventId": eventId
        }),
      );
      return response;
    } catch (e) {
      print("Error al enviar la notificacion: $e");
      throw Exception('Error al enviar la notificacion: $e');
    }
  }



}
