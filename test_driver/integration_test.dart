import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final outputDir =
      '${Directory.current.path}/build/integration_test_screenshots';
  await Directory(outputDir).create(recursive: true);

  await integrationDriver(
    onScreenshot:
        (
          String screenshotName,
          List<int> screenshotBytes, [
          Map<String, Object?>? args,
        ]) async {
          final file = File('$outputDir/$screenshotName.png');
          await file.writeAsBytes(screenshotBytes, flush: true);
          stdout.writeln('Saved screenshot: ${file.path}');
          return screenshotBytes.isNotEmpty;
        },
  );
}
