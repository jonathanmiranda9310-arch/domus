import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'domus_logo.dart';

/// Foto vinda da internet com espaço reservado e entrada suave.
///
/// Enquanto carrega (ou se falhar, ex.: sem internet) mostra um fundo
/// índigo claro com o símbolo do Domus.
class FotoRede extends StatelessWidget {
  const FotoRede(this.url, {super.key, this.fit = BoxFit.cover});

  final String url;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _EspacoReservado(),
        if (url.isNotEmpty)
          Image.network(
            url,
            fit: fit,
            frameBuilder: (context, child, frame, sincrono) {
              if (sincrono) return child;
              return AnimatedOpacity(
                opacity: frame == null ? 0 : 1,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                child: child,
              );
            },
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _EspacoReservado extends StatelessWidget {
  const _EspacoReservado();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primariaClara,
      child: Center(
        child: Opacity(
          opacity: 0.35,
          child: LayoutBuilder(
            builder: (context, c) => DomusLogo(
              altura: (c.maxHeight * 0.35).clamp(16, 64),
              variante: VarianteLogo.simbolo,
            ),
          ),
        ),
      ),
    );
  }
}
