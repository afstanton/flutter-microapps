import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_validation_example/main.dart';

void main() {
  // Set up the test environment to use a larger screen size
  setUpAll(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(800, 1600);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDownAll(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  testWidgets('Initial state of the app', (WidgetTester tester) async {
    await tester.pumpWidget(const FormValidationExample());

    // Verify initial state
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
    expect(find.text('I agree to the terms and conditions'), findsOneWidget);
    expect(find.text('Male'), findsOneWidget);
    expect(find.text('Female'), findsOneWidget);
    expect(find.text('Select an option'), findsOneWidget);
    expect(find.text('Enter your comments'), findsOneWidget);
    expect(find.text('Enter your age'), findsOneWidget);
    expect(find.text('Select your birthdate'), findsOneWidget);

    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
  });

  testWidgets('Form validation works correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FormValidationExample());

    // Verify initial state
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).at(0), 'invalidemail');
    await tester.pump();

    // Tap the Submit button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump();

    // Verify invalid email error message
    expect(find.text('Please enter a valid email address'), findsOneWidget);

    // Enter valid email
    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.pump();

    // Enter short password
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters long'),
        findsOneWidget);

    // Enter valid password
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.pump();

    // Verify checkbox error message when not checked
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump();
    expect(find.text('You must agree before submitting.'), findsOneWidget);

    // Check the checkbox
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    // Verify radio buttons are present
    expect(find.byType(Radio<String>), findsNWidgets(2));

    // Select gender (radio button)
    await tester.tap(find.byType(Radio<String>).at(1)); // Select 'Female'
    await tester.pump();

    // Select an option (dropdown)
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Option 2').last);
    await tester.pump();

    // Verify selected option
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Option 2'),
        findsOneWidget);

    // Enter comments
    await tester.enterText(
        find.byType(TextFormField).at(2), 'These are my comments.');
    await tester.pump();

    // Enter valid age
    await tester.enterText(find.byType(TextFormField).at(3), '25');
    await tester.pump();

    // Open date picker and select a date
    await tester.tap(find.byType(TextFormField).at(4));
    await tester.pumpAndSettle();
    await tester
        .tap(find.text('15').last); // Select the 15th of the current month
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();

    // Ensure the Submit button is present
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Submit');
    expect(submitButtonFinder, findsOneWidget);

    // Submit the form
    await tester.tap(submitButtonFinder);
    await tester.pump();

    // Verify no validation errors
    expect(find.text('Please enter some text'), findsNothing);
    expect(find.text('Please enter a valid email address'), findsNothing);
    expect(
        find.text('Password must be at least 6 characters long'), findsNothing);
    expect(find.text('You must agree before submitting.'), findsNothing);
    expect(find.text('Please enter your age'), findsNothing);
    expect(find.text('Please select your birthdate'), findsNothing);

    // Verify successful submission message
    expect(find.text('Processing Data'), findsOneWidget);
  });
}
