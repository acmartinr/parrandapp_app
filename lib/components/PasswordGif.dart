import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class PasswordGif extends StatefulWidget {
  @override
  _PasswordGifState createState() => _PasswordGifState();
}

class _PasswordGifState extends State<PasswordGif>
    with SingleTickerProviderStateMixin {
  late final GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    // Arranca justo tras el primer frame:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gifController.forward();
    });
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Gif(
        image: const AssetImage('assets/password.gif'),
        controller: _gifController,
        autostart: Autostart.once,
        // placeholder con solo BuildContext:
        placeholder: (context) => const SizedBox.shrink(),
      ),
    );
  }
}
