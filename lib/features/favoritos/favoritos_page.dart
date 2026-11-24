import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/domus_logo.dart';
import '../../data/models/acomodacao.dart';
import '../../injecao.dart';
import '../detalhes/detalhes_page.dart';
import '../explorar/widgets/acomodacao_card.dart';
import '../perfil/widgets/perfil_avatar_button.dart';

/// Acomodações salvas pelo usuário (sincronizadas pelo FavoritosController).
class FavoritosPage extends StatefulWidget {
  const FavoritosPage({super.key});

  @override
  State<FavoritosPage> createState() => _FavoritosPageState();
}

class _FavoritosPageState extends State<FavoritosPage> {
  /// Todas as acomodações em memória (são poucas): filtrar por id fica
  /// instantâneo quando o usuário favorita/desfavorita.
  late final Future<Map<int, Acomodacao>> _todas = Injecao.acomodacoes
      .listarTodas()
      .then((lista) => {for (final a in lista) a.id!: a});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: const [PerfilAvatarButton()],
      ),
      body: FutureBuilder(
        future: _todas,
        builder: (context, snapshot) {
          final todas = snapshot.data;
          if (todas == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListenableBuilder(
            listenable: Injecao.favoritosCtrl,
            builder: (context, _) {
              final lista = Injecao.favoritosCtrl.idsRecentesPrimeiro
                  .map((id) => todas[id])
                  .whereType<Acomodacao>()
                  .toList();
              if (lista.isEmpty) return const _Vazio();

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: lista.length,
                separatorBuilder: (_, __) => const SizedBox(height: 20),
                itemBuilder: (context, i) {
                  final a = lista[i];
                  return AcomodacaoCard(
                    acomodacao: a,
                    heroTag: 'favoritos-${a.id}',
                    favorito: true,
                    onFavoritar: () => Injecao.favoritosCtrl.alternar(a.id!),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetalhesPage(
                        acomodacao: a,
                        heroTag: 'favoritos-${a.id}',
                      ),
                    )),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _Vazio extends StatelessWidget {
  const _Vazio();

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Opacity(
              opacity: 0.5,
              child: DomusLogo(altura: 80, variante: VarianteLogo.simbolo),
            ),
            const SizedBox(height: 16),
            Text('Nenhum favorito ainda', style: texto.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Toque no ♥ de uma acomodação para guardá-la aqui.',
              textAlign: TextAlign.center,
              style:
                  texto.bodyMedium?.copyWith(color: AppColors.textoSecundario),
            ),
          ],
        ),
      ),
    );
  }
}
