import 'package:image_picker/image_picker.dart';

class SignUpData {
  String? nombre;
  String? apellidos;
  String? genero;
  XFile? fotoPerfil;

  String? email;
  String? password;
  DateTime? birthDate;

  SignUpData({
    this.nombre,
    this.apellidos,
    this.genero,
    this.fotoPerfil,
    this.email,
    this.password,
    this.birthDate,
  });
}