import 'dart:convert';
import 'package:http/http.dart' as http;

class EventService {
  final String baseUrl;
  final String likeEventRoute = "events/like";

  EventService({required this.baseUrl});

  Future<http.Response> likeEvent(
      String id, String eventId, bool like, bool multipleEvents) async {
    final url = Uri.parse('$baseUrl$likeEventRoute');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          "userId": id,
          "eventId": eventId,
          "like": like, // "t" para like
          "multipleEvents": multipleEvents,
        }),
      );
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }
}
