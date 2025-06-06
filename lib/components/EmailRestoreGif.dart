import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class EmailRestoreGif extends StatefulWidget {
  @override
  _EmailRestoreGifState createState() => _EmailRestoreGifState();
}

class _EmailRestoreGifState extends State<EmailRestoreGif>
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
        image: const AssetImage('assets/emailanim.gif'),
        controller: _gifController,
        autostart: Autostart.once,
        // placeholder con solo BuildContext:
        placeholder: (context) => const SizedBox.shrink(),
      ),
    );
  }
}
