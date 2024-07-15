import 'package:cat_facts_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'api_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('API Call Tests', () {
    testWidgets('displays title from API', (WidgetTester tester) async {
      final client = MockClient();

      when(client.get(Uri.parse('https://catfact.ninja/fact'))).thenAnswer(
          (_) async => http.Response('{"fact": "Test Title"}', 200));

      await tester.pumpWidget(CatFactsApp(client: client));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Ensure the widget tree is updated

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('displays error message on failed API call',
        (WidgetTester tester) async {
      final client = MockClient();

      when(client.get(Uri.parse('https://catfact.ninja/fact')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      await tester.pumpWidget(CatFactsApp(client: client));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(); // Ensure the widget tree is updated

      expect(find.text('Failed to get a cat fact'), findsOneWidget);
    });
  });
}
