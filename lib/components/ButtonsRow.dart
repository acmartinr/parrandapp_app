// buttonsRow.dart
import 'package:flutter/material.dart';

class ButtonsRow extends StatelessWidget {
  final bool noMoreCards;
  final VoidCallback onNotLike;
  final VoidCallback onDoLike;
  final VoidCallback onShare;

  const ButtonsRow({
    Key? key,
    required this.noMoreCards,
    required this.onNotLike,
    required this.onDoLike,
    required this.onShare,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PressableImageButton(
            normalAsset: 'assets/notlike.png',
            pressedAsset: 'assets/notlikeact.png',
            disabledAsset: 'assets/notlikehid.png',
            enabled: !noMoreCards,
            onTap: onNotLike,
            heroTag: 'btnNotLike',
          ),
          const SizedBox(width: 4),
          _PressableImageButton(
            normalAsset: 'assets/dolike.png',
            pressedAsset: 'assets/dolikeactv.png',
            disabledAsset: 'assets/dolikehid.png',
            enabled: !noMoreCards,
            onTap: onDoLike,
            heroTag: 'doLike',
          ),
          const SizedBox(width: 4),
          _PressableImageButton(
            normalAsset: 'assets/share.png',
            pressedAsset: 'assets/shareact.png',
            disabledAsset: 'assets/sharehid.png',
            enabled: !noMoreCards,
            onTap: onShare,
            heroTag: 'share',
          ),
        ],
      ),
    );
  }
}

class _PressableImageButton extends StatefulWidget {
  final String normalAsset;
  final String pressedAsset;
  final String disabledAsset;
  final bool enabled;
  final VoidCallback onTap;
  final String heroTag;

  const _PressableImageButton({
    Key? key,
    required this.normalAsset,
    required this.pressedAsset,
    required this.disabledAsset,
    required this.enabled,
    required this.onTap,
    required this.heroTag,
  }) : super(key: key);

  @override
  State<_PressableImageButton> createState() => _PressableImageButtonState();
}

class _PressableImageButtonState extends State<_PressableImageButton> {
  bool _isPressed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precacheamos las tres versiones de la imagen
    precacheImage(AssetImage(widget.normalAsset), context);
    precacheImage(AssetImage(widget.pressedAsset), context);
    precacheImage(AssetImage(widget.disabledAsset), context);
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enabled) {
      setState(() {
        _isPressed = true;
      });
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enabled) {
      setState(() {
        _isPressed = false;
      });
      widget.onTap();
    }
  }

  void _handleTapCancel() {
    if (widget.enabled) {
      setState(() {
        _isPressed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = !widget.enabled
        ? widget.disabledAsset
        : (_isPressed ? widget.pressedAsset : widget.normalAsset);

    return SizedBox(
      width: 100,
      height: 100,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: Hero(
          tag: widget.heroTag,
          child: Image.asset(asset),
        ),
      ),
    );
  }
}
