import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../injecao.dart';
import '../../../rotas.dart';

/// Avatar com as iniciais do usuário que abre o Perfil.
///
/// Coloque em `AppBar(actions: const [PerfilAvatarButton()])`.
class PerfilAvatarButton extends StatelessWidget {
  const PerfilAvatarButton({super.key, this.claro = false});

  /// `true` para usar sobre o cabeçalho índigo (sem margem extra).
  final bool claro;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Injecao.sessao,
      builder: (context, _) {
        final usuario = Injecao.sessao.usuario;
        return Padding(
          padding: EdgeInsets.only(right: claro ? 0 : 12),
          child: Tooltip(
            message: 'Meu perfil',
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pushNamed(Rotas.perfil),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: claro
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppColors.primariaClara,
                child: Text(
                  usuario?.iniciais ?? '?',
                  style: TextStyle(
                    color: claro ? Colors.white : AppColors.primaria,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
