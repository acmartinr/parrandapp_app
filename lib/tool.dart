import 'dart:io';
import 'package:image/image.dart';

void main() {
  // Ruta al proyecto (debe ser donde ejecutas el comando)
  final projectDir = Directory.current.path;
  final basePath = '$projectDir/assets/icon_notification.png';

  final file = File(basePath);
  if (!file.existsSync()) {
    stderr.writeln('¡No encuentro el archivo PNG en $basePath!');
    exit(1);
  }

  // Lee y decodifica
  final bytes = file.readAsBytesSync();
  final image = decodePng(bytes);
  if (image == null) {
    stderr.writeln('El archivo no es un PNG válido o está corrupto.');
    exit(1);
  }

  // Mapa de densidades Android con tamaños en px
  const densities = {
    'drawable-mdpi': 24,
    'drawable-hdpi': 36,
    'drawable-xhdpi': 48,
    'drawable-xxhdpi': 72,
    'drawable-xxxhdpi': 96,
  };

  densities.forEach((folder, size) {
    // Redimensiona
    final resized = copyResize(image, width: size, height: size);

    // Carpeta destino
    final outDirPath = '$projectDir/android/app/src/main/res/$folder';
    final outDir = Directory(outDirPath);
    if (!outDir.existsSync()) outDir.createSync(recursive: true);

    // Guarda el PNG
    final outFile = File('$outDirPath/ic_stat_notification.png');
    outFile.writeAsBytesSync(encodePng(resized));
    print('✅ Generado: ${outFile.path}');
  });
}