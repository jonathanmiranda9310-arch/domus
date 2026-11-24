import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'rotas.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DomusApp());
}

class DomusApp extends StatelessWidget {
  const DomusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Domus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      // Idioma pt_BR para date pickers, botões padrão etc.
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Ícones escuros na status bar (fundo claro). A Splash sobrescreve
      // com ícones brancos enquanto está visível.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark
            .copyWith(statusBarColor: Colors.transparent),
        child: child!,
      ),
      // A Splash inicializa o banco e decide entre Login e Home.
      initialRoute: Rotas.splash,
      routes: Rotas.mapa,
    );
  }
}
