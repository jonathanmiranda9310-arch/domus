import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Fundo claro com dois "círculos de luz" suaves (índigo e verde-menta),
/// usado na Splash, Login e Cadastro para dar identidade sem poluir.
class FundoDecorado extends StatelessWidget {
  const FundoDecorado({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tamanho = MediaQuery.sizeOf(context);
    return ColoredBox(
      color: AppColors.fundo,
      child: Stack(
        children: [
          Positioned(
            top: -tamanho.width * 0.35,
            right: -tamanho.width * 0.3,
            child: _Brilho(
              cor: AppColors.primaria.withValues(alpha: 0.13),
              diametro: tamanho.width * 0.95,
            ),
          ),
          Positioned(
            bottom: -tamanho.width * 0.4,
            left: -tamanho.width * 0.35,
            child: _Brilho(
              cor: AppColors.secundaria.withValues(alpha: 0.14),
              diametro: tamanho.width * 1.0,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Brilho extends StatelessWidget {
  const _Brilho({required this.cor, required this.diametro});

  final Color cor;
  final double diametro;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diametro,
      height: diametro,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [cor, cor.withValues(alpha: 0)]),
      ),
    );
  }
}
