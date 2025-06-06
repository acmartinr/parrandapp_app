import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lexi/components/CustomText.dart';

class CarrouselComponentGif extends StatefulWidget {
  final List<String> images;

  CarrouselComponentGif({required this.images});

  @override
  _CarrouselComponentGifState createState() => _CarrouselComponentGifState();
}

class _CarrouselComponentGifState extends State<CarrouselComponentGif> {
  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  static const List<String> _titles = [
    "¡Bienvenido a Parrandapp!",
    "Donde todos sonreímos...",
    "en el mismo lugar."
  ];

  static const List<String> _subtitles = [
    "¡Entérate de los últimos eventos en tu zona o tu localidad!",
    "Interactúa con las personas que les gustaría ir al mismo evento que tú.",
    "¡Gracias a nuestro algoritmo siempre te recomendaremos eventos que vas a amar!"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Wrap del slider con padding lateral
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: CarouselSlider(
            items: widget.images.map((src) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  src,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            }).toList(),
            carouselController: _controller,
            options: CarouselOptions(
              height: 280,
              // un poco más pequeño si quieres
              viewportFraction: 1.0,
              // al haber padding externo, quedan más estrechos
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ),
        // Título dinámico
        CustomText(
          text: _titles[_currentIndex],
          fontSize: 20,
          fontWeight: FontWeight.bold,
          textAlign: TextAlign.center,
          fontFamily: 'SourceSansProBold',
        ),

        const SizedBox(height: 4),

        // Subtítulo dinámico
        CustomText(
          text: _subtitles[_currentIndex],
          fontSize: 16,
          textAlign: TextAlign.center,
          fontFamily: 'SourceSansProRegular',
        ),

        const SizedBox(height: 12),

        // Dots indicadores
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.images.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key
                      ? Color(0xFFFF2B5D)
                      : Colors.grey[400],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
