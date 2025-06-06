import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String labelText;
  final int? fontSizeValue;
  final int? fontSizePlaceHolderValue;
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? hintText;

  const CustomTextFormField({
    Key? key,
    required this.labelText,
    required this.fontSizeValue,
    required this.fontSizePlaceHolderValue,
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(
        fontFamily: 'SourceSansProBold',
        fontSize: fontSizePlaceHolderValue?.toDouble() ?? 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1D1B20),
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontFamily: 'SourceSansProNormal',
          fontSize: fontSizeValue?.toDouble() ?? 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF1D1B20),
        ),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D1B20),
        ),
        // Puedes agregar más propiedades de InputDecoration si lo necesitas
      ),
    );
  }
}
