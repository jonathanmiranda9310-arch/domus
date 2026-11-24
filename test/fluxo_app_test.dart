import 'dart:io';

import 'package:domus/data/database/seed_database.dart';
import 'package:domus/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Teste de ponta a ponta das telas desta parte do projeto:
/// Splash → Login (conta demo) → Home → Perfil → Sair → Login.
void main() {
  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiNoIsolate;
    final pasta = await Directory.systemTemp.createTemp('domus_teste');
    await databaseFactory.setDatabasesPath(pasta.path);
    SharedPreferences.setMockInitialValues({});
  });

  /// Avança frames deixando o I/O real (banco, hash) acontecer.
  Future<void> aguardar(WidgetTester tester, Finder alvo) async {
    for (var i = 0; i < 100 && alvo.evaluate().isEmpty; i++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(alvo, findsWidgets);
  }

  testWidgets('fluxo completo de autenticação e perfil', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340); // celular comum
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const DomusApp());

    // Splash → Login
    await aguardar(tester, find.text('Bem-vindo de volta'));

    // Senha errada mostra mensagem
    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'), SeedDatabase.emailDemo);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'), 'errada');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await aguardar(tester, find.text('E-mail ou senha incorretos.'));

    // Login correto → Home
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'), SeedDatabase.senhaDemo);
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await aguardar(tester, find.text('20 opções'));
    expect(find.text('Sinta-se em casa, onde estiver.'), findsWidgets);

    // Abas
    await tester.tap(find.text('Reservas'));
    await tester.pumpAndSettle();
    expect(find.text('Minhas reservas'), findsWidgets);

    // Avatar → Perfil
    await tester.tap(find.text('VD').first);
    await aguardar(tester, find.text('Visitante Domus'));
    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await aguardar(tester, find.text('Pousada Recanto de Tambaú'));
    expect(find.text('Histórico de estadias'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();

    // Editar nome
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome completo'), 'Visitante Teste');
    await tester.pump();
    await tester.ensureVisible(find.text('Salvar alterações'));
    await tester.tap(find.text('Salvar alterações'));
    await aguardar(tester, find.text('Dados atualizados com sucesso.'));
    await tester.drag(find.byType(ListView), const Offset(0, 3000));
    await tester.pumpAndSettle();
    expect(find.text('VT'), findsOneWidget); // avatar com novas iniciais

    // Sair (espera a SnackBar sumir para não cobrir o botão)
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(ListView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sair da conta'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Sair'));
    await aguardar(tester, find.text('Bem-vindo de volta'));
  });
}
