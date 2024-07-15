import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slider_example/main.dart';

void main() {
  testWidgets('Slider updates value', (WidgetTester tester) async {
    await tester.pumpWidget(const SliderApp());

    expect(find.text('Value: 20'), findsOneWidget);

    // Move the slider
    await tester.drag(find.byType(Slider), const Offset(500, 0));
    await tester.pump();

    // Verify the slider value has changed
    expect(find.text('Value: 100'), findsOneWidget);
  });
}
