import 'package:flutter/material.dart';

/// Categorias de hospedagem (usadas nos chips de filtro da Home).
///
/// No banco é salvo o `name` do enum: 'hotel', 'pousada' ou 'quarto'.
enum CategoriaAcomodacao {
  hotel('Hotel', 'Hotéis', Icons.apartment_rounded),
  pousada('Pousada', 'Pousadas', Icons.cottage_outlined),
  quarto('Quarto', 'Quartos', Icons.bed_outlined);

  const CategoriaAcomodacao(this.rotulo, this.rotuloPlural, this.icone);

  /// "Hotel" — usado no card / detalhes.
  final String rotulo;

  /// "Hotéis" — usado nos chips de filtro.
  final String rotuloPlural;

  final IconData icone;

  /// Converte o texto salvo no banco/JSON para o enum.
  static CategoriaAcomodacao deTexto(String valor) => values.firstWhere(
        (c) => c.name == valor,
        orElse: () => throw ArgumentError('Categoria desconhecida: $valor'),
      );
}
