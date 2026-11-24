import 'package:flutter/material.dart';

import 'features/auth/cadastro_page.dart';
import 'features/auth/login_page.dart';
import 'features/perfil/perfil_page.dart';
import 'features/shell/shell_page.dart';
import 'features/splash/splash_page.dart';

/// Rotas nomeadas do app.
///
/// Telas com argumentos (ex.: Detalhes recebe uma `Acomodacao`) podem
/// usar `Navigator.push(context, MaterialPageRoute(...))` diretamente.
abstract final class Rotas {
  static const splash = '/';
  static const login = '/login';
  static const cadastro = '/cadastro';
  static const home = '/home';
  static const perfil = '/perfil';

  static Map<String, WidgetBuilder> get mapa => {
        splash: (_) => const SplashPage(),
        login: (_) => const LoginPage(),
        cadastro: (_) => const CadastroPage(),
        home: (_) => const ShellPage(),
        perfil: (_) => const PerfilPage(),
      };
}
