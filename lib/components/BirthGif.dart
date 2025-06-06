import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class BirthGif extends StatefulWidget {
  @override
  _BirthGifState createState() => _BirthGifState();
}

class _BirthGifState extends State<BirthGif>
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
      width: 140,
      height: 140,
      child: Gif(
        image: const AssetImage('assets/birthday.gif'),
        controller: _gifController,
        autostart: Autostart.once,
        // placeholder con solo BuildContext:
        placeholder: (context) => const SizedBox.shrink(),
      ),
    );
  }
}
