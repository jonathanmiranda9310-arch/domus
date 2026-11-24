import 'dart:convert';

import '../../core/utils/calculos.dart';
import 'categoria_acomodacao.dart';
import 'comodidade.dart';

/// Hotel, pousada ou quarto disponível para reserva.
///
/// Os dados vêm do JSON em `assets/data/acomodacoes.json` (seed) e
/// ficam salvos na tabela `acomodacoes`.
class Acomodacao {
  const Acomodacao({
    this.id,
    required this.nome,
    required this.categoria,
    required this.descricao,
    required this.endereco,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.valorDiaria,
    required this.notaMedia,
    required this.totalAvaliacoes,
    required this.capacidadeMaxima,
    required this.fotos,
    required this.comodidades,
  });

  final int? id;
  final String nome;
  final CategoriaAcomodacao categoria;
  final String descricao;

  /// Rua e número, ex.: "Av. Cabo Branco, 2500".
  final String endereco;
  final String bairro;
  final String cidade;

  /// Sigla da UF, ex.: "PB".
  final String estado;

  final double valorDiaria;

  /// Nota de 0 a 5.
  final double notaMedia;
  final int totalAvaliacoes;

  /// Número máximo de hóspedes.
  final int capacidadeMaxima;

  /// URLs das fotos. A primeira é a foto principal (usada no card).
  final List<String> fotos;
  final List<Comodidade> comodidades;

  // ---------------------------------------------------------------------------
  // Atalhos para as telas
  // ---------------------------------------------------------------------------

  /// Foto do card. String vazia se não houver fotos.
  String get fotoPrincipal => fotos.isNotEmpty ? fotos.first : '';

  /// "João Pessoa - PB" (linha de localização do card).
  String get cidadeEstado => '$cidade - $estado';

  /// "Tambaú, João Pessoa - PB"
  String get localizacao => '$bairro, $cidade - $estado';

  /// "Av. Cabo Branco, 2500 - Tambaú, João Pessoa - PB" (tela de detalhes).
  String get enderecoCompleto => '$endereco - $bairro, $cidade - $estado';

  bool possui(Comodidade comodidade) => comodidades.contains(comodidade);

  /// Valor total da estadia: valorDiaria × noites.
  double calcularValorTotal(DateTime checkIn, DateTime checkOut) =>
      Calculos.valorTotal(
        valorDiaria: valorDiaria,
        checkIn: checkIn,
        checkOut: checkOut,
      );

  // ---------------------------------------------------------------------------
  // Conversão JSON/banco <-> objeto
  // ---------------------------------------------------------------------------

  /// Aceita tanto o JSON do seed (listas de verdade) quanto a linha do
  /// banco (listas salvas como texto JSON).
  factory Acomodacao.fromMap(Map<String, Object?> map) {
    return Acomodacao(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      categoria: CategoriaAcomodacao.deTexto(map['categoria'] as String),
      descricao: map['descricao'] as String? ?? '',
      endereco: map['endereco'] as String? ?? '',
      bairro: map['bairro'] as String? ?? '',
      cidade: map['cidade'] as String,
      estado: map['estado'] as String,
      valorDiaria: (map['valor_diaria'] as num).toDouble(),
      notaMedia: (map['nota_media'] as num? ?? 0).toDouble(),
      totalAvaliacoes: map['total_avaliacoes'] as int? ?? 0,
      capacidadeMaxima: map['capacidade_maxima'] as int? ?? 2,
      fotos: _lerLista(map['fotos']).map((e) => e.toString()).toList(),
      comodidades: Comodidade.deLista(_lerLista(map['comodidades'])),
    );
  }

  /// Mapa para a tabela `acomodacoes` (listas viram texto JSON).
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'categoria': categoria.name,
      'descricao': descricao,
      'endereco': endereco,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
      'valor_diaria': valorDiaria,
      'nota_media': notaMedia,
      'total_avaliacoes': totalAvaliacoes,
      'capacidade_maxima': capacidadeMaxima,
      'fotos': jsonEncode(fotos),
      'comodidades': jsonEncode(comodidades.map((c) => c.name).toList()),
    };
  }

  static List<dynamic> _lerLista(Object? valor) {
    if (valor == null) return const [];
    if (valor is List) return valor;
    if (valor is String && valor.isNotEmpty) {
      return jsonDecode(valor) as List<dynamic>;
    }
    return const [];
  }

  @override
  bool operator ==(Object other) => other is Acomodacao && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Acomodacao(id: $id, nome: $nome)';
}
