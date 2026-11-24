import 'package:domus/core/theme/app_theme.dart';
import 'package:domus/features/auth/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login valida campos vazios antes de consultar o banco',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.claro, home: const LoginPage()),
    );

    expect(find.text('Bem-vindo de volta'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();

    expect(find.text('Informe seu e-mail'), findsOneWidget);
    expect(find.text('Informe sua senha'), findsOneWidget);
  });
}
