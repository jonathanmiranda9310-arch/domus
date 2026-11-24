import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Conteúdo provisório das telas que outros integrantes vão implementar.
class EmConstrucao extends StatelessWidget {
  const EmConstrucao({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.detalhe,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final String? detalhe;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primariaClara,
              child: Icon(icone, size: 32, color: AppColors.primaria),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(titulo, style: texto.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style:
                  texto.bodyMedium?.copyWith(color: AppColors.textoSecundario),
            ),
            if (detalhe != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(detalhe!, style: texto.labelLarge),
            ],
          ],
        ),
      ),
    );
  }
}
