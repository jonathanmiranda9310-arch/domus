import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// Caixa de erro exibida acima do botão do formulário.
class MensagemErro extends StatelessWidget {
  const MensagemErro(this.mensagem, {super.key});

  final String mensagem;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.erroClaro,
        borderRadius: AppRadius.controleBorder,
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.erro, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensagem,
              style: const TextStyle(color: AppColors.erro, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
