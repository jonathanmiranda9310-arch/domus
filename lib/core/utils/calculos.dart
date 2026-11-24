import 'datas.dart';

/// Regras de cálculo de valores da reserva.
abstract final class Calculos {
  /// Regra do projeto: valorTotal = valorDiaria × número de noites.
  static double valorTotal({
    required double valorDiaria,
    required DateTime checkIn,
    required DateTime checkOut,
  }) {
    final noites = Datas.calcularNoites(checkIn, checkOut);
    return arredondar(valorDiaria * noites);
  }

  /// Arredonda para 2 casas decimais (centavos).
  static double arredondar(double valor) => (valor * 100).roundToDouble() / 100;
}
