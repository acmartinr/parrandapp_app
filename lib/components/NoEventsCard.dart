import 'package:flutter/material.dart';
import 'package:lexi/components/NoEventsGif.dart';

class NoEventsCard extends StatelessWidget {
  const NoEventsCard({Key? key}) : super(key: key);
  static const String noEventTitle = 'No hay más eventos';
  static const String noEventText =
      'Por el momento no tenemos más recomendaciones para ti. ¡En poco tiempo te mostraremos más eventos para que puedas seguir de parranda!';

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Center(
      child: Container(
        // Ancho al 90% de la pantalla, margen superior al 20%
        width: size.width * 0.9,
        margin: EdgeInsets.only(top: size.height * 0.20),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(color: Color(0xFFADACCA), width: 5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tu gif o icono animado
                NoEventsGif(),

                SizedBox(height: 10),

                // Título
                Text(
                  noEventTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'SourceSansPro',
                    color: Color(0xFF1D1B20),
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),

                // Descripción
                Text(
                  noEventText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1D1B20),
                    fontFamily: 'SourceSansProNormal',
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    height: 1.4,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
