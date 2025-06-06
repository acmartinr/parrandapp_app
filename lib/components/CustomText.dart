import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final String fontFamily;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const CustomText({
    Key? key,
    required this.text,
    this.fontSize = 18,
    this.fontWeight = FontWeight.w700,
    this.color = const Color(0xFF1D1B20),
    this.fontFamily = 'SourceSansPro',
    this.textAlign,
    this.maxLines,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: fontFamily,
              color: Color(0xFF1D1B20),
              fontWeight: fontWeight,
              fontSize: fontSize,
            )));
  }
}
