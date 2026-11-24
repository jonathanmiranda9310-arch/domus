import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatadores.dart';
import '../../../core/widgets/foto_rede.dart';
import '../../../data/models/reserva.dart';

/// Lista das estadias concluídas do usuário.
class HistoricoEstadias extends StatelessWidget {
  const HistoricoEstadias({super.key, required this.estadias});

  final List<ReservaComAcomodacao> estadias;

  @override
  Widget build(BuildContext context) {
    if (estadias.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Icon(Icons.luggage_outlined,
                  size: 36, color: AppColors.textoDesabilitado),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Você ainda não concluiu nenhuma estadia.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textoSecundario),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          for (var i = 0; i < estadias.length; i++) ...[
            if (i > 0) const Divider(indent: 88),
            _ItemEstadia(item: estadias[i]),
          ],
        ],
      ),
    );
  }
}

class _ItemEstadia extends StatelessWidget {
  const _ItemEstadia({required this.item});

  final ReservaComAcomodacao item;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final reserva = item.reserva;
    final acomodacao = item.acomodacao;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.controleBorder,
            child: SizedBox(
                width: 56,
                height: 56,
                child: FotoRede(acomodacao.fotoPrincipal)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  acomodacao.nome,
                  style: texto.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(acomodacao.cidadeEstado, style: texto.bodySmall),
                const SizedBox(height: 2),
                Text(
                  '${Formatadores.periodo(reserva.checkIn, reserva.checkOut)}'
                  ' · ${Formatadores.noites(reserva.noites)}',
                  style: texto.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(Formatadores.moeda(reserva.valorTotal), style: texto.titleSmall),
        ],
      ),
    );
  }
}
