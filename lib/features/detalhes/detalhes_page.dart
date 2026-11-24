import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/datas.dart';
import '../../core/utils/formatadores.dart';
import '../../core/widgets/foto_rede.dart';
import '../../data/models/acomodacao.dart';
import '../../injecao.dart';
import '../explorar/widgets/acomodacao_card.dart';

/// Detalhes da acomodação: galeria, descrição, comodidades, localização
/// e cálculo automático do valor total conforme as datas.
///
/// O botão "Reservar agora" chama [_reservar], ponto de integração com a
/// tela de Confirmação de Reserva (feita por outro integrante).
class DetalhesPage extends StatefulWidget {
  const DetalhesPage({
    super.key,
    required this.acomodacao,
    required this.heroTag,
    this.checkIn,
    this.checkOut,
    this.hospedes,
  });

  final Acomodacao acomodacao;
  final String heroTag;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final int? hospedes;

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  late DateTime? _checkIn = widget.checkIn;
  late DateTime? _checkOut = widget.checkOut;
  int _fotoAtual = 0;

  Acomodacao get _a => widget.acomodacao;

  int get _noites => (_checkIn != null && _checkOut != null)
      ? Datas.calcularNoites(_checkIn!, _checkOut!)
      : 0;

  Future<void> _escolherDatas() async {
    final hoje = Datas.hoje();
    final escolha = await showDateRangePicker(
      context: context,
      firstDate: hoje,
      lastDate: hoje.add(const Duration(days: 365)),
      initialDateRange:
          _noites > 0 ? DateTimeRange(start: _checkIn!, end: _checkOut!) : null,
      helpText: 'Datas da estadia',
      saveText: 'Confirmar',
    );
    if (escolha == null ||
        Datas.calcularNoites(escolha.start, escolha.end) < 1) {
      return;
    }
    setState(() {
      _checkIn = escolha.start;
      _checkOut = escolha.end;
    });
  }

  /// Ponto de integração com a Confirmação de Reserva.
  ///
  /// Quem implementar a reserva deve trocar o corpo por algo como:
  /// `Navigator.push(context, MaterialPageRoute(builder: (_) =>
  ///   ConfirmacaoReservaPage(acomodacao: _a, checkIn: _checkIn, ...)));`
  Future<void> _reservar() async {
    if (_noites == 0) {
      await _escolherDatas();
      if (_noites == 0) return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${Formatadores.noites(_noites)} por '
          '${Formatadores.moeda(_a.calcularValorTotal(_checkIn!, _checkOut!))}. '
          'Confirmação de reserva em desenvolvimento.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final alturaGaleria = MediaQuery.sizeOf(context).width * 0.85;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: alturaGaleria,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primaria,
              foregroundColor: Colors.white,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              leading: const Padding(
                padding: EdgeInsets.all(8),
                child: _BotaoCircular(icone: Icons.arrow_back_rounded),
              ),
              actions: [
                ListenableBuilder(
                  listenable: Injecao.favoritosCtrl,
                  builder: (context, _) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: BotaoFavorito(
                      favorito: Injecao.favoritosCtrl.isFavorito(_a.id!),
                      onPressed: () => Injecao.favoritosCtrl.alternar(_a.id!),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _galeria(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Etiqueta(
                          icone: _a.categoria.icone,
                          texto: _a.categoria.rotulo,
                        ),
                        const SizedBox(width: 8),
                        _Etiqueta(
                          icone: Icons.people_outline_rounded,
                          texto:
                              'Até ${Formatadores.hospedes(_a.capacidadeMaxima)}',
                        ),
                        const Spacer(),
                        SeloNota(acomodacao: _a, escuro: false),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(_a.nome, style: texto.headlineSmall),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.primaria),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_a.localizacao,
                              style: texto.bodyMedium
                                  ?.copyWith(color: AppColors.textoSecundario)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _cartaoDatas(),
                    const _Titulo('Sobre'),
                    Text(
                      _a.descricao,
                      style: texto.bodyLarge?.copyWith(
                          color: AppColors.texto.withValues(alpha: 0.85)),
                    ),
                    const _Titulo('Comodidades'),
                    _comodidades(),
                    const _Titulo('Onde fica'),
                    _localizacao(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _barraReserva(),
      ),
    );
  }

  Widget _galeria() {
    final fotos = _a.fotos.isEmpty ? [''] : _a.fotos;
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: fotos.length,
          onPageChanged: (i) => setState(() => _fotoAtual = i),
          itemBuilder: (_, i) => i == 0
              ? Hero(tag: widget.heroTag, child: FotoRede(fotos[i]))
              : FotoRede(fotos[i]),
        ),
        // Sombra no topo para os botões e status bar ficarem legíveis.
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x66000000), Colors.transparent],
              ),
            ),
          ),
        ),
        if (fotos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < fotos.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _fotoAtual ? 22 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _fotoAtual
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _cartaoDatas() {
    final temDatas = _noites > 0;
    return Material(
      color: AppColors.primariaClara.withValues(alpha: 0.6),
      borderRadius: AppRadius.cardBorder,
      child: InkWell(
        onTap: _escolherDatas,
        borderRadius: AppRadius.cardBorder,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_month_rounded,
                    color: AppColors.primaria),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temDatas
                          ? Formatadores.periodo(_checkIn!, _checkOut!)
                          : 'Quando você vai?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      temDatas
                          ? '${Formatadores.noites(_noites)} · toque para alterar'
                          : 'Escolha as datas para ver o valor total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.primaria),
            ],
          ),
        ),
      ),
    );
  }

  Widget _comodidades() {
    return LayoutBuilder(builder: (context, c) {
      final largura = (c.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final item in _a.comodidades)
            SizedBox(
              width: largura,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.secundariaClara,
                      borderRadius: AppRadius.controleBorder,
                    ),
                    child: Icon(item.icone,
                        size: 20, color: const Color(0xFF047857)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.rotulo,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  Widget _localizacao() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.cardBorder,
        border: Border.all(color: AppColors.borda),
      ),
      child: Row(
        children: [
          const Icon(Icons.map_outlined, color: AppColors.primaria),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_a.enderecoCompleto,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  /// Barra fixa inferior: diária, total e "Reservar agora".
  Widget _barraReserva() {
    final total =
        _noites > 0 ? _a.calcularValorTotal(_checkIn!, _checkOut!) : null;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.texto.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(
                        text: Formatadores.moedaCurta(_a.valorDiaria),
                        style: AppTextStyles.preco.copyWith(fontSize: 20),
                      ),
                      const TextSpan(
                          text: ' /noite', style: AppTextStyles.sufixoPreco),
                    ])),
                    if (total != null)
                      Text(
                        'Total ${Formatadores.moeda(total)}',
                        style: const TextStyle(
                          color: AppColors.secundaria,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else
                      Text('Escolha as datas',
                          style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              FilledButton(
                onPressed: _reservar,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(170, 52),
                ),
                child: const Text('Reservar agora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoCircular extends StatelessWidget {
  const _BotaoCircular({required this.icone});

  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icone, color: AppColors.texto, size: 22),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primariaClara,
        borderRadius: BorderRadius.circular(AppRadius.pilula),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: AppColors.primaria),
          const SizedBox(width: 4),
          Text(texto,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primariaEscura)),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 28, bottom: 12),
      child: Text(texto, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
