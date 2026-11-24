/// Utilitários de texto.
abstract final class Texto {
  static const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  static const _semAcento = 'aaaaaeeeeiiiiooooouuuucn';

  /// Deixa o texto minúsculo e sem acentos, para buscas tolerantes.
  ///
  /// "João Pessoa" → "joao pessoa"
  static String normalizar(String texto) {
    final minusculo = texto.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final char in minusculo.split('')) {
      final i = _comAcento.indexOf(char);
      buffer.write(i >= 0 ? _semAcento[i] : char);
    }
    return buffer.toString();
  }

  /// Iniciais para avatar: "Maria da Silva" → "MS"
  static String iniciais(String nome) {
    final partes =
        nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first[0].toUpperCase();
    return (partes.first[0] + partes.last[0]).toUpperCase();
  }

  /// Mantém apenas os dígitos: "(83) 99999-8888" → "83999998888"
  static String somenteDigitos(String texto) =>
      texto.replaceAll(RegExp(r'\D'), '');
}
