import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker_example/main.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

void main() {
  late String tempFilePath;
  late Uint8List fileContent;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    tempFilePath = path.join(tempDir.path, 'temp_file.txt');
    fileContent = Uint8List.fromList('Hello, world.'.codeUnits);

    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(fileContent);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/file_selector'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'openFile') {
        return {
          'type': 'success',
          'name': 'temp_file.txt',
          'path': tempFilePath,
          'bytes': fileContent,
          'length': fileContent.length
        };
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/file_selector'), null);

    final tempFile = File(tempFilePath);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  });

  testWidgets('Initial state of the app', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FilePickerHome(),
    ));

    // Verify the initial state
    expect(find.text('Read'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.textContaining('File Content:'), findsNothing);
  });

  testWidgets('Read button opens file picker and reads file content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FilePickerHome(),
    ));

    // Simulate tapping the Read button
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();

    // Verify file content after reading
    expect(
        find.text('File Content: ${fileContent.length} bytes'), findsOneWidget);
  });
}
