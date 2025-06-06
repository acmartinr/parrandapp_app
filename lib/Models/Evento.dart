import 'dart:convert';

class Evento {
  final int id;
  final String name;
  final String? date;
  final String? start_date;
  final String? end_date;
  final String? time;
  final String place_name;
  final String description;
  final String? url; // Definir explícitamente como String? para permitir nulos
  final int liked;

  Evento({
    required this.id,
    required this.name,
    this.date,
    this.start_date,
    this.end_date,
    this.time,
    required this.place_name,
    required this.description,
    this.url,
    this.liked = 0, // Valor por defecto para liked
  });

  // Método para convertir un objeto Evento a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'start_date': start_date,
      'end_date': end_date,
      'time': time,
      'place_name': place_name,
      'description': description,
      'url': url,
      'liked': liked,
    };
  }

  // Método de fábrica para crear una instancia desde JSON
  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      // Si el ID es nulo, asigna 0
      name: json['name'] ?? 'Evento sin nombre',
      // Si el nombre es nulo, asigna un valor predeterminado
      date: json['date'],
      // Si es nulo, sigue siendo null
      start_date: json['start_date'],
      // Si es nulo, sigue siendo null
      end_date: json['end_date'],
      // Si es nulo, sigue siendo null
      time: json['time'],
      // Si es nulo, sigue siendo null
      place_name: json['place_name'] ?? 'Lugar desconocido',
      // Valor por defecto si es nulo
      description: json['description'] ?? 'Sin descripción',
      // Valor por defecto si es nulo
      url: json['url'] as String?,
      // Permite valores nulos o cadena
      liked: json['liked'] ?? 0, // Valor por defecto si es nulo
    );
  }
}
