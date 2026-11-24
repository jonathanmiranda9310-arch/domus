import 'package:intl/intl.dart';

/// Formatação de valores para exibição (padrão brasileiro).
///
/// Obs.: as datas em pt_BR exigem `initializeDateFormatting('pt_BR')`,
/// que já é chamado em `Injecao.inicializar()`.
abstract final class Formatadores {
  static final NumberFormat _moeda =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final NumberFormat _moedaSemCentavos =
      NumberFormat.currency(locale: 'pt_BR', symbol: r'R$', decimalDigits: 0);
  static final NumberFormat _nota = NumberFormat('0.0', 'pt_BR');

  /// 1234.5 → "R$ 1.234,50"
  static String moeda(num valor) => _moeda.format(valor);

  /// 220 → "R$ 220" (ideal para o valor da diária nos cards).
  static String moedaCurta(num valor) =>
      valor % 1 == 0 ? _moedaSemCentavos.format(valor) : _moeda.format(valor);

  /// 4.7 → "4,7"
  static String nota(num valor) => _nota.format(valor);

  /// 23/11/2026
  static String data(DateTime data) =>
      DateFormat('dd/MM/yyyy', 'pt_BR').format(data);

  /// "23 nov."
  static String dataCurta(DateTime data) =>
      DateFormat('d MMM', 'pt_BR').format(data);

  /// "dom., 23 de nov."
  static String dataComDiaSemana(DateTime data) =>
      DateFormat("EEE, d 'de' MMM", 'pt_BR').format(data);

  /// "nov. de 2026"
  static String mesAno(DateTime data) =>
      DateFormat("MMM 'de' yyyy", 'pt_BR').format(data);

  /// "23 nov. – 26 nov."
  static String periodo(DateTime checkIn, DateTime checkOut) =>
      '${dataCurta(checkIn)} – ${dataCurta(checkOut)}';

  /// 1 → "1 noite", 3 → "3 noites"
  static String noites(int quantidade) =>
      quantidade == 1 ? '1 noite' : '$quantidade noites';

  /// 1 → "1 hóspede", 2 → "2 hóspedes"
  static String hospedes(int quantidade) =>
      quantidade == 1 ? '1 hóspede' : '$quantidade hóspedes';

  /// "83999998888" → "(83) 99999-8888"
  static String telefone(String? digitos) {
    if (digitos == null || digitos.isEmpty) return '';
    final d = digitos.replaceAll(RegExp(r'\D'), '');
    if (d.length == 11) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    }
    if (d.length == 10) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 6)}-${d.substring(6)}';
    }
    return d;
  }
}
