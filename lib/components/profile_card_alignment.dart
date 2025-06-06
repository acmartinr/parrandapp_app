import 'package:flutter/material.dart';
import 'package:lexi/Models/Evento.dart';
import 'package:lexi/utils/util.dart';

class ProfileCardAlignment extends StatelessWidget {
  final int cardNum;
  final Evento evento;

  ProfileCardAlignment(this.cardNum, {required this.evento});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      // importante para que los hijos no se desborden
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
        side: BorderSide(
          color: Color(0xFFADACCA), // Color del borde
          width: 5, // Ancho del borde
        ),
      ),
      child: Stack(
        children: [
          // Imagen de fondo
          Positioned.fill(
            child: Image.asset(
              'assets/eventimg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa oscura para mejor legibilidad
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                  stops: [0.0, 0.65],
                  // El gradiente cambia hasta la mitad, luego se mantiene transparente.
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ),
          // Contenido de texto encima
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      // <- aquí
                      child: Text(
                        evento.place_name,
                        style: TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    evento.start_date! == evento.end_date
                        ? Text(
                            Utils.convertDateTimeToShortFormat(
                                    evento.start_date!) ??
                                'Por confirmar',
                            style: TextStyle(color: Colors.white),
                          )
                        : Text(
                            '${Utils.convertDateTimeToShortFormat(evento.start_date!)} - ${Utils.convertDateTimeToShortFormat(evento.end_date!)}',
                            style: TextStyle(color: Colors.white),
                          ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  evento.description,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Cantidad de personas o ícono arriba a la derecha
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFADACCA),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 6.0),
                // <-- Baja solo el contenido
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      'assets/group.png',
                      width: 80,
                      height: 80,
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: Container(
                        margin: EdgeInsets.only(top: 8, right: 8),
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          evento.liked.toString(),
                          style: TextStyle(
                            color: Color(0xFFADACCA),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
