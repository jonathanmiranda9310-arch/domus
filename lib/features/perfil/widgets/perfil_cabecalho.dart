import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatadores.dart';
import '../../../data/models/usuario.dart';

/// Resumo numérico exibido no topo do Perfil.
class ResumoPerfil {
  const ResumoPerfil({
    required this.estadias,
    required this.proximas,
    required this.favoritos,
  });

  final int estadias;
  final int proximas;
  final int favoritos;
}

/// Avatar, nome, e-mail e números do usuário.
class PerfilCabecalho extends StatelessWidget {
  const PerfilCabecalho({super.key, required this.usuario, this.resumo});

  final Usuario usuario;
  final ResumoPerfil? resumo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaria,
                  child: Text(
                    usuario.iniciais,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nome,
                        style: texto.titleLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usuario.email,
                        style: texto.bodyMedium
                            ?.copyWith(color: AppColors.textoSecundario),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Membro desde ${Formatadores.mesAno(usuario.criadoEm)}',
                        style: texto.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _Numero(valor: resumo?.estadias, rotulo: 'Estadias'),
                _Numero(valor: resumo?.proximas, rotulo: 'Próximas'),
                _Numero(valor: resumo?.favoritos, rotulo: 'Favoritos'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Numero extends StatelessWidget {
  const _Numero({required this.valor, required this.rotulo});

  final int? valor;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Text(
            valor?.toString() ?? '–',
            style: texto.headlineSmall?.copyWith(color: AppColors.primaria),
          ),
          Text(rotulo, style: texto.bodySmall),
        ],
      ),
    );
  }
}
