import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/datas.dart';
import '../../core/utils/formatadores.dart';
import '../../core/widgets/domus_logo.dart';
import '../../data/models/models.dart';
import '../../injecao.dart';
import '../detalhes/detalhes_page.dart';
import '../perfil/widgets/perfil_avatar_button.dart';
import 'widgets/acomodacao_card.dart';

/// Tela Explorar (Home): cabeçalho com slogan, busca (destino, datas,
/// hóspedes), chips de categoria, filtros rápidos e a lista de cards.
class ExplorarPage extends StatefulWidget {
  const ExplorarPage({super.key});

  @override
  State<ExplorarPage> createState() => _ExplorarPageState();
}

class _ExplorarPageState extends State<ExplorarPage> {
  FiltroBusca _filtro = const FiltroBusca(hospedes: 1);
  late Future<List<Acomodacao>> _resultado = _buscar();

  final _destinoCtrl = TextEditingController();
  Timer? _atrasoBusca;

  Future<List<Acomodacao>> _buscar() => Injecao.acomodacoes.buscar(_filtro);

  void _aplicar(FiltroBusca novo) {
    setState(() {
      _filtro = novo;
      _resultado = _buscar();
    });
  }

  /// Busca enquanto digita, com um pequeno atraso (debounce).
  void _aoDigitarDestino(String texto) {
    _atrasoBusca?.cancel();
    _atrasoBusca = Timer(const Duration(milliseconds: 350), () {
      _aplicar(texto.trim().isEmpty
          ? _filtro.copyWith(limparDestino: true)
          : _filtro.copyWith(destino: texto));
    });
  }

  Future<void> _escolherDatas() async {
    final hoje = Datas.hoje();
    final escolha = await showDateRangePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDateRange: _filtro.temDatas
          ? DateTimeRange(start: _filtro.checkIn!, end: _filtro.checkOut!)
          : null,
      helpText: 'Quando você vai?',
      saveText: 'Confirmar',
    );
    if (escolha == null) return;
    if (Datas.calcularNoites(escolha.start, escolha.end) < 1) return;
    _aplicar(_filtro.copyWith(checkIn: escolha.start, checkOut: escolha.end));
  }

  Future<void> _escolherHospedes() async {
    final valor = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) => _SeletorHospedes(inicial: _filtro.hospedes ?? 1),
    );
    if (valor != null) _aplicar(_filtro.copyWith(hospedes: valor));
  }

  void _abrirDetalhes(Acomodacao a) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DetalhesPage(
        acomodacao: a,
        heroTag: 'explorar-${a.id}',
        checkIn: _filtro.checkIn,
        checkOut: _filtro.checkOut,
        hospedes: _filtro.hospedes,
      ),
    ));
  }

  @override
  void dispose() {
    _destinoCtrl.dispose();
    _atrasoBusca?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Cabeçalho índigo → ícones da status bar brancos.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: () async {
            _aplicar(_filtro);
            await _resultado;
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _cabecalho()),
              SliverToBoxAdapter(child: _categorias()),
              SliverToBoxAdapter(child: _filtrosRapidos()),
              _lista(),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Cabeçalho: marca, saudação, slogan e cartão de busca
  // ---------------------------------------------------------------------------

  Widget _cabecalho() {
    final topo = MediaQuery.paddingOf(context).top;
    final nome = Injecao.sessao.usuario?.primeiroNome ?? 'viajante';

    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, topo + 12, 20, 64),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1),
                AppColors.primaria,
                Color(0xFF3730A3)
              ],
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  DomusMarca(altura: 30, claro: true),
                  Spacer(),
                  PerfilAvatarButton(claro: true),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Olá, $nome!',
                style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                AppInfo.slogan,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
        // O cartão de busca "flutua" sobre a borda do cabeçalho.
        Transform.translate(
          offset: const Offset(0, -40),
          child: _cartaoBusca(),
        ),
      ],
    );
  }

  Widget _cartaoBusca() {
    final f = _filtro;
    final textoDatas = f.temDatas
        ? Formatadores.periodo(f.checkIn!, f.checkOut!)
        : 'Escolher datas';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaria.withValues(alpha: 0.18),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _destinoCtrl,
            onChanged: _aoDigitarDestino,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Para onde você vai?',
              prefixIcon:
                  const Icon(Icons.search_rounded, color: AppColors.primaria),
              suffixIcon: _destinoCtrl.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _destinoCtrl.clear();
                        _aoDigitarDestino('');
                      },
                    ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _CampoBusca(
                    icone: Icons.calendar_today_rounded,
                    rotulo: f.temDatas
                        ? Formatadores.noites(f.noites!)
                        : 'Check-in · Check-out',
                    valor: textoDatas,
                    onTap: _escolherDatas,
                  ),
                ),
                const VerticalDivider(width: 1, indent: 12, endIndent: 12),
                Expanded(
                  child: _CampoBusca(
                    icone: Icons.person_outline_rounded,
                    rotulo: 'Hóspedes',
                    valor: Formatadores.hospedes(f.hospedes ?? 1),
                    onTap: _escolherHospedes,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Chips de categoria e filtros rápidos
  // ---------------------------------------------------------------------------

  Widget _categorias() {
    final opcoes = <(CategoriaAcomodacao?, String, IconData)>[
      (null, 'Todos', Icons.grid_view_rounded),
      for (final c in CategoriaAcomodacao.values) (c, c.rotuloPlural, c.icone),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Sem espaço no topo: o cartão de busca deslocado já deixa o respiro.
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: opcoes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (categoria, rotulo, icone) = opcoes[i];
          final selecionado = _filtro.categoria == categoria;
          return _ChipFiltro(
            rotulo: rotulo,
            icone: icone,
            selecionado: selecionado,
            onTap: () => _aplicar(categoria == null
                ? _filtro.copyWith(limparCategoria: true)
                : _filtro.copyWith(categoria: categoria)),
          );
        },
      ),
    );
  }

  Widget _filtrosRapidos() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        children: [
          for (final faixa in FaixaPreco.values) ...[
            _ChipFiltro(
              rotulo: faixa.rotulo,
              pequeno: true,
              selecionado: _filtro.faixaPreco == faixa,
              onTap: () => _aplicar(_filtro.faixaPreco == faixa
                  ? _filtro.copyWith(limparFaixaPreco: true)
                  : _filtro.copyWith(faixaPreco: faixa)),
            ),
            const SizedBox(width: 8),
          ],
          _ChipFiltro(
            rotulo: '4,5+',
            icone: Icons.star_rounded,
            pequeno: true,
            selecionado: _filtro.notaMinima == 4.5,
            onTap: () => _aplicar(_filtro.notaMinima == 4.5
                ? _filtro.copyWith(limparNotaMinima: true)
                : _filtro.copyWith(notaMinima: 4.5)),
          ),
          const SizedBox(width: 8),
          _ChipFiltro(
            rotulo: 'Menor preço',
            icone: Icons.south_rounded,
            pequeno: true,
            selecionado: _filtro.ordenacao == OrdenacaoBusca.menorPreco,
            onTap: () => _aplicar(_filtro.copyWith(
                ordenacao: _filtro.ordenacao == OrdenacaoBusca.menorPreco
                    ? OrdenacaoBusca.relevancia
                    : OrdenacaoBusca.menorPreco)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Lista de resultados
  // ---------------------------------------------------------------------------

  Widget _lista() {
    return FutureBuilder<List<Acomodacao>>(
      future: _resultado,
      builder: (context, snapshot) {
        final lista = snapshot.data;
        if (lista == null) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (lista.isEmpty) {
          return SliverToBoxAdapter(child: _SemResultados(onLimpar: () {
            _destinoCtrl.clear();
            _aplicar(const FiltroBusca(hospedes: 1));
          }));
        }

        return SliverMainAxisGroup(slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _filtro.destino?.isNotEmpty == true
                          ? 'Resultados'
                          : 'Lugares para você',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lista.length} ${lista.length == 1 ? 'opção' : 'opções'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          ListenableBuilder(
            listenable: Injecao.favoritosCtrl,
            builder: (context, _) => SliverList.separated(
              itemCount: lista.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (context, i) {
                final a = lista[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AcomodacaoCard(
                    acomodacao: a,
                    heroTag: 'explorar-${a.id}',
                    noites: _filtro.temDatas ? _filtro.noites : null,
                    favorito: Injecao.favoritosCtrl.isFavorito(a.id!),
                    onFavoritar: () => Injecao.favoritosCtrl.alternar(a.id!),
                    onTap: () => _abrirDetalhes(a),
                  ),
                );
              },
            ),
          ),
        ]);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Componentes privados da tela
// -----------------------------------------------------------------------------

class _CampoBusca extends StatelessWidget {
  const _CampoBusca({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.onTap,
  });

  final IconData icone;
  final String rotulo;
  final String valor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
        child: Row(
          children: [
            Icon(icone, size: 20, color: AppColors.primaria),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rotulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall),
                  const SizedBox(height: 2),
                  Text(valor,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  const _ChipFiltro({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
    this.icone,
    this.pequeno = false,
  });

  final String rotulo;
  final IconData? icone;
  final bool selecionado;
  final bool pequeno;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final corConteudo = selecionado ? Colors.white : AppColors.texto;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selecionado ? AppColors.primaria : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.pilula),
        border: Border.all(
          color: selecionado ? AppColors.primaria : AppColors.borda,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pilula),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pequeno ? 12 : 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icone != null) ...[
                Icon(icone,
                    size: pequeno ? 15 : 18,
                    color: selecionado
                        ? Colors.white
                        : (icone == Icons.star_rounded
                            ? AppColors.estrela
                            : AppColors.primaria)),
                const SizedBox(width: 6),
              ],
              Text(
                rotulo,
                style: TextStyle(
                  color: corConteudo,
                  fontWeight: FontWeight.w600,
                  fontSize: pequeno ? 12.5 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SemResultados extends StatelessWidget {
  const _SemResultados({required this.onLimpar});

  final VoidCallback onLimpar;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 48, 32, 0),
      child: Column(
        children: [
          const Opacity(
            opacity: 0.5,
            child: DomusLogo(altura: 72, variante: VarianteLogo.simbolo),
          ),
          const SizedBox(height: 16),
          Text('Nada por aqui… ainda', style: texto.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Tente outro destino ou remova alguns filtros.',
            textAlign: TextAlign.center,
            style: texto.bodyMedium?.copyWith(color: AppColors.textoSecundario),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: onLimpar,
            style: OutlinedButton.styleFrom(minimumSize: const Size(180, 46)),
            child: const Text('Limpar filtros'),
          ),
        ],
      ),
    );
  }
}

class _SeletorHospedes extends StatefulWidget {
  const _SeletorHospedes({required this.inicial});

  final int inicial;

  @override
  State<_SeletorHospedes> createState() => _SeletorHospedesState();
}

class _SeletorHospedesState extends State<_SeletorHospedes> {
  late int _valor = widget.inicial;

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Quantos hóspedes?', style: texto.titleLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  onPressed: _valor > 1 ? () => setState(() => _valor--) : null,
                  icon: const Icon(Icons.remove_rounded),
                ),
                SizedBox(
                  width: 96,
                  child: Text(
                    '$_valor',
                    textAlign: TextAlign.center,
                    style: texto.headlineMedium,
                  ),
                ),
                IconButton.outlined(
                  onPressed: _valor < 8 ? () => setState(() => _valor++) : null,
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pop(context, _valor),
              child: const Text('Aplicar'),
            ),
          ],
        ),
      ),
    );
  }
}
