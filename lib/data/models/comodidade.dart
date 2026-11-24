import 'package:flutter/material.dart';

/// Comodidades que uma acomodação pode oferecer.
///
/// Cada uma já traz o rótulo e o ícone, para a tela de Detalhes apenas
/// fazer: `Icon(c.icone)` + `Text(c.rotulo)`.
/// No banco/JSON é salvo o `name` (ex.: "wifi", "cafeDaManha").
enum Comodidade {
  wifi('Wi-Fi', Icons.wifi_rounded),
  cafeDaManha('Café da manhã', Icons.free_breakfast_outlined),
  arCondicionado('Ar-condicionado', Icons.ac_unit_rounded),
  estacionamento('Estacionamento', Icons.local_parking_rounded),
  piscina('Piscina', Icons.pool_rounded),
  cozinha('Cozinha', Icons.kitchen_outlined),
  tv('TV', Icons.tv_rounded),
  aceitaPets('Aceita pets', Icons.pets_rounded),
  academia('Academia', Icons.fitness_center_rounded),
  vistaMar('Vista para o mar', Icons.beach_access_outlined);

  const Comodidade(this.rotulo, this.icone);

  final String rotulo;
  final IconData icone;

  /// Converte uma lista de textos para comodidades, ignorando valores
  /// desconhecidos (assim um JSON antigo não quebra o app).
  static List<Comodidade> deLista(Iterable<dynamic> valores) {
    final porNome = {for (final c in values) c.name: c};
    return valores
        .map((v) => porNome[v.toString()])
        .whereType<Comodidade>()
        .toList();
  }
}
