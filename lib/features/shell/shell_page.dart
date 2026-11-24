import 'package:flutter/material.dart';

import '../../injecao.dart';
import '../explorar/explorar_page.dart';
import '../favoritos/favoritos_page.dart';
import '../minhas_reservas/minhas_reservas_page.dart';

/// Estrutura principal após o login: Bottom Navigation com 3 abas.
///
/// O Perfil não é uma aba: é aberto pelo avatar no topo das telas
/// (widget `PerfilAvatarButton`).
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _abaAtual = 0;

  @override
  void initState() {
    super.initState();
    // Carrega os favoritos do usuário logado (corações nos cards).
    final usuarioId = Injecao.sessao.usuario?.id;
    if (usuarioId != null) Injecao.favoritosCtrl.carregar(usuarioId);
  }

  // IndexedStack mantém o estado de cada aba ao trocar.
  static const _abas = [
    ExplorarPage(),
    FavoritosPage(),
    MinhasReservasPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _abaAtual, children: _abas),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: NavigationBar(
          selectedIndex: _abaAtual,
          onDestinationSelected: (i) => setState(() => _abaAtual = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Reservas',
            ),
          ],
        ),
      ),
    );
  }
}
