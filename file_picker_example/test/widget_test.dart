import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker_example/main.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';

// Mock class for XFile
class MockXFile implements XFile {
  @override
  final String path;
  final Uint8List bytes;

  MockXFile(this.path, this.bytes);

  @override
  Future<Uint8List> readAsBytes() async => bytes;

  @override
  String get name => path.split('/').last;

  @override
  Future<int> length() async => bytes.length;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late String tempFilePath;
  late Uint8List fileContent;
  bool writeCalled = false;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    tempFilePath = path.join(tempDir.path, 'temp_file.txt');
    fileContent = Uint8List.fromList('Hello, world.'.codeUnits);

    final tempFile = File(tempFilePath);
    await tempFile.writeAsBytes(fileContent);

    // Mock method call handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/file_selector'),
            (MethodCall methodCall) async {
      if (methodCall.method == 'openFile') {
        return [tempFilePath];
      }
      return null;
    });

    // Setting the mock file selector platform
    FileSelectorPlatform.instance = MockFileSelectorPlatform(
      mockFile: MockXFile(tempFilePath, fileContent),
      saveFilePath: tempFilePath,
    );
  });

  tearDown(() {
    // Clear the mock method call handler
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/file_selector'), null);

    final tempFile = File(tempFilePath);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }
  });

  testWidgets('Read button opens file picker and reads file content',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FilePickerHome(),
    ));

    // Verify initial state
    expect(find.text('Read'), findsOneWidget);
    expect(find.byType(ElevatedButton),
        findsNWidgets(2)); // Now there are two buttons
    expect(find.textContaining('File Content:'), findsNothing);

    // Simulate tapping the Read button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Read'));
    await tester.pumpAndSettle();

    // Verify file content after reading
    expect(find.textContaining('File Content: ${fileContent.length} bytes'),
        findsOneWidget);
  });

  testWidgets('Write button is enabled after reading a file',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: FilePickerHome(),
    ));

    // Verify initial state
    expect(find.text('Write'), findsOneWidget);
    final writeButton = tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Write'));
    expect(writeButton.onPressed, isNull);

    // Simulate tapping the Read button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Read'));
    await tester.pumpAndSettle();

    // Verify Write button is enabled after reading a file
    final enabledWriteButton = tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Write'));
    expect(enabledWriteButton.onPressed, isNotNull);
  });

  testWidgets('Write button calls the correct function when clicked',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FilePickerHome(
        onWrite: () {
          writeCalled = true;
        },
      ),
    ));

    // Simulate tapping the Read button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Read'));
    await tester.pumpAndSettle();

    // Verify Write button is enabled after reading a file
    final enabledWriteButton = tester
        .widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Write'));
    expect(enabledWriteButton.onPressed, isNotNull);

    // Simulate tapping the Write button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Write'));
    await tester.pumpAndSettle();

    // Verify the callback is called
    expect(writeCalled, isTrue);
  });
}

// Mock file selector platform
class MockFileSelectorPlatform extends FileSelectorPlatform {
  final MockXFile mockFile;
  final String saveFilePath;

  MockFileSelectorPlatform({
    required this.mockFile,
    required this.saveFilePath,
  });

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    return mockFile;
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions? options,
  }) async {
    return FileSaveLocation(saveFilePath);
  }
}
