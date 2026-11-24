import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatadores.dart';
import '../../../core/widgets/foto_rede.dart';
import '../../../data/models/acomodacao.dart';

/// Card de acomodação usado na lista do Explorar e em Favoritos.
///
/// Mostra foto principal, categoria, nota, nome, localização,
/// comodidades principais e o valor da diária (e o total, se houver datas).
class AcomodacaoCard extends StatelessWidget {
  const AcomodacaoCard({
    super.key,
    required this.acomodacao,
    required this.favorito,
    required this.onFavoritar,
    required this.onTap,
    required this.heroTag,
    this.noites,
  });

  final Acomodacao acomodacao;
  final bool favorito;
  final VoidCallback onFavoritar;
  final VoidCallback onTap;

  /// Tag única da foto para a animação até a tela de Detalhes.
  final String heroTag;

  /// Se o usuário escolheu datas, mostra o total da estadia.
  final int? noites;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final a = acomodacao;

    return Container(
      decoration: BoxDecoration(
        borderRadius: AppRadius.cardBorder,
        boxShadow: [
          BoxShadow(
            color: AppColors.texto.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardBorder),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ----------------------------------------------- Foto
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(tag: heroTag, child: FotoRede(a.fotoPrincipal)),
                    // Escurece levemente o rodapé da foto para o selo de nota.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.center,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Color(0x55000000)],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: SeloCategoria(acomodacao: a),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: BotaoFavorito(
                        favorito: favorito,
                        onPressed: onFavoritar,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      bottom: 12,
                      child: SeloNota(acomodacao: a),
                    ),
                  ],
                ),
              ),
              // ----------------------------------------------- Informações
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.nome,
                      style: texto.titleMedium?.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 16, color: AppColors.textoSecundario),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            a.localizacao,
                            style: texto.bodySmall?.copyWith(fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Até 3 comodidades em ícones discretos.
                        for (final c in a.comodidades.take(3))
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Tooltip(
                              message: c.rotulo,
                              child: Icon(c.icone,
                                  size: 18, color: AppColors.textoDesabilitado),
                            ),
                          ),
                        const Spacer(),
                        _Preco(acomodacao: a, noites: noites),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Preco extends StatelessWidget {
  const _Preco({required this.acomodacao, this.noites});

  final Acomodacao acomodacao;
  final int? noites;

  @override
  Widget build(BuildContext context) {
    final temTotal = noites != null && noites! > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: Formatadores.moedaCurta(acomodacao.valorDiaria),
              style: AppTextStyles.preco,
            ),
            const TextSpan(text: ' /noite', style: AppTextStyles.sufixoPreco),
          ]),
        ),
        if (temTotal)
          Text(
            '${Formatadores.moeda(acomodacao.valorDiaria * noites!)} · '
            '${Formatadores.noites(noites!)}',
            style: const TextStyle(
              color: AppColors.secundaria,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

/// Pílula branca com o ícone e o nome da categoria.
class SeloCategoria extends StatelessWidget {
  const SeloCategoria({super.key, required this.acomodacao});

  final Acomodacao acomodacao;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(AppRadius.pilula),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(acomodacao.categoria.icone, size: 14, color: AppColors.primaria),
          const SizedBox(width: 4),
          Text(
            acomodacao.categoria.rotulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.texto,
            ),
          ),
        ],
      ),
    );
  }
}

/// Nota média com estrela.
class SeloNota extends StatelessWidget {
  const SeloNota({super.key, required this.acomodacao, this.escuro = true});

  final Acomodacao acomodacao;

  /// `true` = texto branco (sobre foto); `false` = texto grafite.
  final bool escuro;

  @override
  Widget build(BuildContext context) {
    final corTexto = escuro ? Colors.white : AppColors.texto;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppColors.estrela),
        const SizedBox(width: 3),
        Text(
          Formatadores.nota(acomodacao.notaMedia),
          style: TextStyle(
            color: corTexto,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          ' (${acomodacao.totalAvaliacoes})',
          style: TextStyle(
            color: corTexto.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Coração em círculo branco, com animação ao favoritar.
class BotaoFavorito extends StatelessWidget {
  const BotaoFavorito({
    super.key,
    required this.favorito,
    required this.onPressed,
  });

  final bool favorito;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: favorito ? 'Remover dos favoritos' : 'Salvar nos favoritos',
        onPressed: onPressed,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: Icon(
            favorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(favorito),
            color: favorito ? const Color(0xFFF43F5E) : AppColors.texto,
            size: 22,
          ),
        ),
      ),
    );
  }
}
