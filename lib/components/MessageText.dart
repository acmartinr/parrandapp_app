import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lexi/components/ProfileAvatarWithGap.dart';
import 'dart:math' as math;

class MessageText extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  final String senderName;
  final String avatarUrl;
  final String time;
  final bool adminMessage;

  MessageText(
      {required this.text,
      required this.isSentByMe,
      required this.senderName,
      required this.avatarUrl,
      required this.time,
      required this.adminMessage});

  @override
  Widget build(BuildContext context) {
    final bgColor = isSentByMe ? Color(0xFF24B675) : Colors.white!;
    final textColor = isSentByMe ? Colors.white : Color(0xFF1D1B20);
    final align = isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start;

    final avatar = Container(
      //padding: EdgeInsets.all(4),
      child: adminMessage
          ? Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Image.asset('assets/chatprofileimage.png',
                  width: 42, height: 42),
            )
          : (!isSentByMe && avatarUrl.isEmpty)
              ? Container(
                  width: 42,
                  height:
                      42, // Igual que el ancho para que sea un círculo perfecto
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    // Le indica que el contenedor debe ser circular
                    image: DecorationImage(
                      image: AssetImage('assets/defaultimage.png'),
                      fit: BoxFit.cover, // Cubre todo el círculo sin deformar
                    ),
                  ),
                )
              : ProfileAvatarWithGap(
                  imageProvider: adminMessage
                      ? AssetImage("assets/chatprofileimage.png")
                      : (avatarUrl.isEmpty && isSentByMe)
                          ? AssetImage("assets/defaultimageme.png")
                          : NetworkImage(avatarUrl) as ImageProvider,
                  size: 48.0,
                  strokeWidth: 4.0,
                  gapAngle: math.pi / 4,
                  // o el que prefieras
                  borderColor: isSentByMe && avatarUrl.isNotEmpty
                      ? Color(0xFF24B675)
                      : Colors.transparent,
                ),
    );

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: align,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSentByMe) avatar,
          SizedBox(width: 20),
          Container(
            width: 250,
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isSentByMe ? 20 : 0),
                topRight: Radius.circular(isSentByMe ? 0 : 20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // sigue alineando todo a la izquierda
              children: [
                Text(
                  senderName,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: 'SourceSansProNormal',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: isSentByMe ? textColor : Color(0xFFADACCA),
                  ),
                ),
                Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: textColor,
                    fontFamily: 'SourceSansProNormal',
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isSentByMe ? textColor : Color(0xFFADACCA),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          if (isSentByMe) avatar,
        ],
      ),
    );
  }
}
