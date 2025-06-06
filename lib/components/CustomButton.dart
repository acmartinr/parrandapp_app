import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  // Puedes agregar más parámetros si necesitas que el botón sea aún más flexible
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0, // Quita la elevación
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1D1B20),
        ),
        backgroundColor: const Color(0xFF24B675), // Fondo verde
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20), // Radio de 20
        ),
      ),
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 2,
        ),
      )
          : Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: 'SourceSansProBold',
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}