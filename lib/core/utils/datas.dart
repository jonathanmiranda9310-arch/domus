/// Funções de data usadas em reservas, busca e listagens.
///
/// Todas as datas de estadia são tratadas como "dia do calendário"
/// (sem hora), para que o cálculo de noites não sofra com fuso horário
/// ou horário de verão.
abstract final class Datas {
  /// Remove hora/minuto/segundo, mantendo apenas o dia.
  static DateTime somenteData(DateTime data) =>
      DateTime(data.year, data.month, data.day);

  /// Data de hoje, sem hora.
  static DateTime hoje() => somenteData(DateTime.now());

  /// Número de noites entre check-in e check-out (checkOut − checkIn).
  ///
  /// Retorna 0 se o check-out não for posterior ao check-in.
  static int calcularNoites(DateTime checkIn, DateTime checkOut) {
    // Usa UTC para que todo dia tenha exatamente 24h no cálculo.
    final inicio = DateTime.utc(checkIn.year, checkIn.month, checkIn.day);
    final fim = DateTime.utc(checkOut.year, checkOut.month, checkOut.day);
    final dias = fim.difference(inicio).inDays;
    return dias > 0 ? dias : 0;
  }

  /// `true` se [a] é antes de [b], comparando só o dia.
  static bool antesDe(DateTime a, DateTime b) =>
      somenteData(a).isBefore(somenteData(b));

  /// Converte para o formato salvo no banco: `yyyy-MM-dd`.
  ///
  /// Esse formato permite comparar datas direto no SQL (`check_in >= ?`).
  static String paraIso(DateTime data) {
    final m = data.month.toString().padLeft(2, '0');
    final d = data.day.toString().padLeft(2, '0');
    return '${data.year.toString().padLeft(4, '0')}-$m-$d';
  }

  /// Lê uma data `yyyy-MM-dd` (ou ISO completa) vinda do banco.
  static DateTime deIso(String texto) => somenteData(DateTime.parse(texto));
}
