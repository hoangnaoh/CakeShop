import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:CakeShop_app/screens/auth/login_screen.dart';

void main() {
  testWidgets('LoginScreen UI contains text fields and button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // Verify that the title is displayed
    expect(find.text('CakeShop'), findsOneWidget);
    expect(find.text('Đăng nhập để tiếp tục'), findsOneWidget);

    // Verify that there are two text fields
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify the login button is present
    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
