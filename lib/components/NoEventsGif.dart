import 'package:flutter/material.dart';
import 'package:gif/gif.dart';

class NoEventsGif extends StatefulWidget {
  @override
  _NoEventsGifState createState() => _NoEventsGifState();
}

class _NoEventsGifState extends State<NoEventsGif>
    with SingleTickerProviderStateMixin {
  late GifController _gifController;

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
  }

  @override
  void dispose() {
    _gifController.dispose();
    super.dispose();
  }

  void _playOnce() {
    _gifController.reset();
    _gifController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: _playOnce,            // ➜ Al hacer tap, anima
        child: SizedBox(
          width: 200,
          height: 200,
          child: Gif(
            image: const AssetImage('assets/no_events.gif'),
            controller: _gifController,
            autostart: Autostart.no,       // No arranca solo
            placeholder: (ctx) =>
            const Center(child: CircularProgressIndicator()),
            onFetchCompleted: () {
              // Al cargar, lanza la primera vez
              _playOnce();
            },
          ),
        ),
      ),
    );
  }
}