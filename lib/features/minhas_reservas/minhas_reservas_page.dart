import 'package:flutter/material.dart';

import '../perfil/widgets/perfil_avatar_button.dart';
import '../shell/em_construcao.dart';

/// PROVISÓRIO — abas "Próximas" / "Concluídas" são de outro integrante.
///
/// Dados disponíveis:
/// - `Injecao.reservas.listarProximas(usuarioId)`
/// - `Injecao.reservas.listarConcluidas(usuarioId)`
/// - `Injecao.reservas.cancelar(reservaId)`
/// - `item.reserva.situacao()` → rótulo e cores do badge de status
class MinhasReservasPage extends StatelessWidget {
  const MinhasReservasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas reservas'),
        actions: const [PerfilAvatarButton()],
      ),
      body: const EmConstrucao(
        icone: Icons.calendar_month_outlined,
        titulo: 'Minhas reservas',
        descricao: 'Reservas próximas e concluídas.\n'
            'Em desenvolvimento por outro integrante.',
      ),
    );
  }
}
