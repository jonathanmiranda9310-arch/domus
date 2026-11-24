import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Variações da logo disponíveis em `assets/images/`.
enum VarianteLogo {
  /// Símbolo + escrita "DOMUS" (Splash, Login).
  completa('assets/images/logo.png'),

  /// Só o símbolo (casa-pino), para espaços pequenos.
  simbolo('assets/images/logo_icone.png'),

  /// Símbolo em branco + verde, para fundos índigo.
  simboloBranco('assets/images/logo_icone_branco.png');

  const VarianteLogo(this.caminho);
  final String caminho;
}

/// Logo oficial do Domus.
class DomusLogo extends StatelessWidget {
  const DomusLogo({
    super.key,
    this.altura = 120,
    this.variante = VarianteLogo.completa,
  });

  final double altura;
  final VarianteLogo variante;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      variante.caminho,
      height: altura,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      semanticLabel: 'Logo Domus',
    );
  }
}

/// Símbolo + nome "Domus" lado a lado (cabeçalhos).
class DomusMarca extends StatelessWidget {
  const DomusMarca({super.key, this.altura = 32, this.claro = false});

  final double altura;

  /// `true` para usar sobre fundo índigo.
  final bool claro;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DomusLogo(
          altura: altura,
          variante: claro ? VarianteLogo.simboloBranco : VarianteLogo.simbolo,
        ),
        SizedBox(width: altura * 0.28),
        Text(
          'Domus',
          style: TextStyle(
            fontSize: altura * 0.7,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: claro ? Colors.white : AppColors.primaria,
          ),
        ),
      ],
    );
  }
}
