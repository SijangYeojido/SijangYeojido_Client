import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';
import 'package:path/path.dart' as path;

Future<void> main() async {
  final outputDir = path.join(
    Directory.current.path,
    'build',
    'integration_test_screenshots',
  );
  await Directory(outputDir).create(recursive: true);

  await integrationDriver(
    onScreenshot:
        (
          String screenshotName,
          List<int> screenshotBytes, [
          Map<String, Object?>? args,
        ]) async {
          final file = File(path.join(outputDir, '$screenshotName.png'));
          await file.writeAsBytes(screenshotBytes, flush: true);
          print('Saved screenshot: ${file.path}');
          return screenshotBytes.isNotEmpty;
        },
  );
}
