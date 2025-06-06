import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utils {
  static const String baseUrl = 'http://parrandapp.com:3002/api/';
  static const String baseUrlImage = 'http://parrandapp.com:3002/';

  // Static method to generate a random string
  static String generateRandomString(int length) {
    const characters =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length)),
      ),
    );
  }

  static String convertDateTimeToShortFormat(String date) {
    // Verificar si la fecha está en formato ISO 8601 o mm/dd/yyyy
    DateTime parsedDate;

    try {
      // Intentar parsear como ISO 8601
      parsedDate = DateTime.parse(date).toLocal();
    } catch (e) {
      // Si falla, asumir formato mm/dd/yyyy
      List<String> parts = date.split('/');
      int month = int.parse(parts[0]);
      int day = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      parsedDate = DateTime(year, month, day);
    }

    // Meses en español
    List<String> months = [
      '', // Índice 0 vacío para alinear con el mes 1 = enero
      'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sept', 'oct', 'nov', 'dic'
    ];

    // Obtener partes de la fecha
    String day = parsedDate.day.toString();
    String monthName = months[parsedDate.month];
    String year = parsedDate.year.toString();

    // Retornar la fecha formateada
    return '$day $monthName de $year';
  }

  /// Valida que el email no esté vacío y tenga formato correcto.
  static bool isValidEmail(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

}
