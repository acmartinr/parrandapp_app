import 'package:http/http.dart' as http;

class TagsService {
  final String baseUrl;
  final String getAllTagsRoute = "tags/";

  TagsService({required this.baseUrl});

  Future<http.Response> getAllTags() async {
    final url = Uri.parse('$baseUrl$getAllTagsRoute');
    try {
      print("Sending request to: $url");
      final response = await http.get(url);
      return response;
    } catch (e) {
      print("Error al enviar la notificacion: $e");
      throw Exception('Error al enviar la notificacion: $e');
    }
  }
}
