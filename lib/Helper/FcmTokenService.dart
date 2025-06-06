import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmTokenService {
  final String baseUrl;
  final String updateFcmRoute = "fcm/update";

  FcmTokenService({required this.baseUrl});

  Future<http.Response> update(String userId,String fcm) async {
    final url = Uri.parse('$baseUrl$updateFcmRoute');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:
        jsonEncode(<String, String>{
          "userId": userId,
          "fcm": fcm
        }),
      );
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }



}
