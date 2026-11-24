import '../../core/utils/datas.dart';
import 'categoria_acomodacao.dart';

/// Faixas de preço para os filtros rápidos (chips).
enum FaixaPreco {
  ate150('Até R\$ 150', null, 150),
  de150a300('R\$ 150 – 300', 150, 300),
  acima300('Acima de R\$ 300', 300, null);

  const FaixaPreco(this.rotulo, this.minimo, this.maximo);

  final String rotulo;
  final double? minimo;
  final double? maximo;
}

/// Ordenação dos resultados.
enum OrdenacaoBusca {
  relevancia('Relevância'),
  menorPreco('Menor preço'),
  maiorNota('Melhor avaliação');

  const OrdenacaoBusca(this.rotulo);
  final String rotulo;
}

/// Parâmetros da busca da tela Explorar.
///
/// Todos os campos são opcionais: um `FiltroBusca()` vazio lista tudo.
///
/// Exemplo:
/// ```dart
/// final filtro = FiltroBusca(
///   destino: 'joao pessoa',
///   categoria: CategoriaAcomodacao.pousada,
///   faixaPreco: FaixaPreco.ate150,
/// );
/// final lista = await Injecao.acomodacoes.buscar(filtro);
/// ```
class FiltroBusca {
  const FiltroBusca({
    this.destino,
    this.checkIn,
    this.checkOut,
    this.hospedes,
    this.categoria,
    this.faixaPreco,
    this.notaMinima,
    this.ordenacao = OrdenacaoBusca.relevancia,
  });

  /// Texto livre: cidade, bairro, estado ou nome. Ignora acentos.
  final String? destino;
  final DateTime? checkIn;
  final DateTime? checkOut;

  /// Filtra acomodações com capacidade para esse número de hóspedes.
  final int? hospedes;
  final CategoriaAcomodacao? categoria;
  final FaixaPreco? faixaPreco;

  /// Ex.: 4.0 ou 4.5.
  final double? notaMinima;
  final OrdenacaoBusca ordenacao;

  /// Noites selecionadas (null se as datas não foram escolhidas).
  int? get noites => (checkIn != null && checkOut != null)
      ? Datas.calcularNoites(checkIn!, checkOut!)
      : null;

  bool get temDatas => noites != null && noites! > 0;

  /// Para limpar um campo, passe `limparX: true`.
  FiltroBusca copyWith({
    String? destino,
    DateTime? checkIn,
    DateTime? checkOut,
    int? hospedes,
    CategoriaAcomodacao? categoria,
    FaixaPreco? faixaPreco,
    double? notaMinima,
    OrdenacaoBusca? ordenacao,
    bool limparDestino = false,
    bool limparDatas = false,
    bool limparCategoria = false,
    bool limparFaixaPreco = false,
    bool limparNotaMinima = false,
  }) {
    return FiltroBusca(
      destino: limparDestino ? null : (destino ?? this.destino),
      checkIn: limparDatas ? null : (checkIn ?? this.checkIn),
      checkOut: limparDatas ? null : (checkOut ?? this.checkOut),
      hospedes: hospedes ?? this.hospedes,
      categoria: limparCategoria ? null : (categoria ?? this.categoria),
      faixaPreco: limparFaixaPreco ? null : (faixaPreco ?? this.faixaPreco),
      notaMinima: limparNotaMinima ? null : (notaMinima ?? this.notaMinima),
      ordenacao: ordenacao ?? this.ordenacao,
    );
  }
}
