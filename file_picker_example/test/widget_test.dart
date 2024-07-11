import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker_example/main.dart';
import 'package:file_picker_example/file_selector_service.dart';
import 'package:mockito/mockito.dart';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';

class MockFileSelectorService extends Mock implements FileSelectorService {}

void main() {
  late MockFileSelectorService mockFileSelectorService;

  setUp(() {
    mockFileSelectorService = MockFileSelectorService();
  });

  testWidgets('Initial state of the app', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FilePickerHome(fileSelectorService: mockFileSelectorService),
    ));

    // Verify the initial state
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
    final writeButton =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(writeButton.onPressed, isNull);
  });

  testWidgets('Read button enables Write button after file selection',
      (WidgetTester tester) async {
    final testFileContent = Uint8List.fromList('Hello, world.'.codeUnits);
    final mockXFile = XFile.fromData(testFileContent);

    when(mockFileSelectorService.openFileDialog())
        .thenAnswer((_) async => mockXFile);

    await tester.pumpWidget(MaterialApp(
      home: FilePickerHome(fileSelectorService: mockFileSelectorService),
    ));

    // Simulate tapping the Read button
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();

    // Verify the Write button is enabled after reading a file
    final writeButton =
        tester.widget<ElevatedButton>(find.byType(ElevatedButton).last);
    expect(writeButton.onPressed, isNotNull);
  });

  testWidgets('Write button saves file', (WidgetTester tester) async {
    final testFileContent = Uint8List.fromList('Hello, world.'.codeUnits);
    final mockXFile = XFile.fromData(testFileContent);
    final mockSaveLocation = FileSaveLocation('/path/to/output.txt');

    when(mockFileSelectorService.openFileDialog())
        .thenAnswer((_) async => mockXFile);

    when(mockFileSelectorService.getSaveLocationDialog())
        .thenAnswer((_) async => mockSaveLocation);

    await tester.pumpWidget(MaterialApp(
      home: FilePickerHome(fileSelectorService: mockFileSelectorService),
    ));

    // Simulate tapping the Read button
    await tester.tap(find.text('Read'));
    await tester.pumpAndSettle();

    // Simulate tapping the Write button
    await tester.tap(find.text('Write'));
    await tester.pumpAndSettle();

    // Verify the file was saved
    verify(mockFileSelectorService.getSaveLocationDialog()).called(1);
  });
}
