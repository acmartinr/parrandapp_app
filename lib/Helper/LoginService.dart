import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class LoginService {
  final String baseUrl;
  final String loginRoute = "login";
  final String signUpRoute = "signup";
  final String updateRoute = "signup/update";
  final String deleteRoute = "signup/delete/";
  final String forgotPasswordRoute = "login/reset-password";
  final String checkEmailRoute = "login/check-email";
  final String userRoute = "signup/";

  LoginService({required this.baseUrl});

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl$loginRoute');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body:
            jsonEncode(<String, String>{'email': email, 'password': password}),
      );
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> signUp(
      String name,
      String lastname,
      String email,
      String sex,
      String birthdate,
      String password,
      XFile? _pickedImage,
      List<int> tags) async {
    final url = Uri.parse('$baseUrl$signUpRoute');

    try {
      print("Sending request to: $url");
      var request = http.MultipartRequest('POST', url);
      request.fields['name'] = name;
      request.fields['lastname'] = lastname;
      request.fields['email'] = email;
      request.fields['sex'] = sex;
      request.fields['birthdate'] = birthdate;
      request.fields['password'] = password;
      String? extension = _pickedImage?.path.split('.').last.toLowerCase();
      MediaType contentType = (extension == 'png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg'); // Asumimos jpeg si no es png
      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            _pickedImage!.path,
            contentType: contentType,
          ),
        );
      }
      request.fields['tags'] = tags.toString();

      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> update(
      String name,
      String lastname,
      String email,
      String sex,
      String birthdate,
      String password,
      int id,
      XFile? _pickedImage) async {
    final url = Uri.parse('$baseUrl$updateRoute');
    try {
      print("Sending request to: $url");
      var request = http.MultipartRequest('POST', url);
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['lastname'] = lastname;
      request.fields['email'] = email;
      request.fields['sex'] = sex;
      request.fields['birthdate'] = birthdate;
      request.fields['password'] = password;

      String? extension = _pickedImage?.path.split('.').last.toLowerCase();
      MediaType contentType = (extension == 'png')
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg'); // Asumimos jpeg si no es png

      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            _pickedImage!.path,
            contentType: contentType,
          ),
        );
      }
      var streamed = await request.send();
      var response = await http.Response.fromStream(streamed);
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> delete(String id) async {
    final url = Uri.parse('$baseUrl$deleteRoute$id');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{}),
      );
      print("Response status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl$forgotPasswordRoute');
    try {
      print("Sending request to: $url");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, String>{'email': email}),
      );

      // Decodificar la respuesta para buscar campo 'error'
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data.containsKey('error')) {
        // Si viene 'error', lanzamos una excepción específica
        throw Exception('No se encontró una cuenta asociada a este email.');
      }

      // Si no hay error, devolvemos la respuesta original
      return response;
    } catch (e) {
      print("Error al enviar la solicitud o procesar la respuesta: $e");
      // Re-lanzamos la excepción para que quien llame al método la gestione
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> checkEmail(String email) async {
    final url = Uri.parse('$baseUrl$checkEmailRoute')
        .replace(queryParameters: {'email': email.trim()});

    try {
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'});

      return response;
    } catch (e) {
      print("Error al enviar la solicitud: $e");
      throw Exception('Error al enviar la solicitud: $e');
    }
  }

  Future<http.Response> getUserById(String id) async {
    final url = Uri.parse('$baseUrl$userRoute$id');
    try {
      final response = await http.get(url,
          headers: {'Content-Type': 'application/json; charset=UTF-8'});

      return response;
    } catch (e) {
      print("Error al obtener el usuario: $e");
      throw Exception('Error al obtener el usuario: $e');
    }
  }
}
