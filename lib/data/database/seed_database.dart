import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/utils/datas.dart';
import '../models/acomodacao.dart';
import '../models/reserva.dart';
import '../repositories/acomodacao_repository.dart';
import '../repositories/favorito_repository.dart';
import '../repositories/reserva_repository.dart';
import '../repositories/usuario_repository.dart';

/// Popula o banco na primeira execução.
///
/// 1. Lê `assets/data/acomodacoes.json` e grava as acomodações.
/// 2. Cria uma conta de demonstração com uma reserva concluída, uma
///    futura e um favorito, para as telas não abrirem vazias na
///    apresentação.
///
/// Nas execuções seguintes, só insere acomodações novas do JSON.
class SeedDatabase {
  SeedDatabase({
    required this.acomodacoes,
    required this.usuarios,
    required this.reservas,
    required this.favoritos,
    Future<String> Function()? carregarJson,
    this.criarContaDemo = true,
  }) : _carregarJson =
            carregarJson ?? (() => rootBundle.loadString(caminhoAsset));

  static const caminhoAsset = 'assets/data/acomodacoes.json';

  static const emailDemo = 'demo@domus.app';
  static const senhaDemo = 'domus123';

  final AcomodacaoRepository acomodacoes;
  final UsuarioRepository usuarios;
  final ReservaRepository reservas;
  final FavoritoRepository favoritos;
  final Future<String> Function() _carregarJson;
  final bool criarContaDemo;

  Future<void> executar() async {
    final json = jsonDecode(await _carregarJson()) as List<dynamic>;
    final lista = json
        .map((item) => Acomodacao.fromMap(Map<String, Object?>.from(item)))
        .toList();

    final existentes = await acomodacoes.contar();
    // Nada novo no JSON: não mexe no banco.
    if (existentes >= lista.length) return;

    // Insere só as que faltam (ids já existentes são ignorados), então
    // acomodações novas no JSON aparecem sem apagar reservas/favoritos.
    await acomodacoes.inserirVarias(lista);
    debugPrint('[Seed] ${lista.length - existentes} acomodações novas.');

    if (criarContaDemo && existentes == 0) await _criarContaDemo();
  }

  Future<void> _criarContaDemo() async {
    if (await usuarios.emailEmUso(emailDemo)) return;

    final usuario = await usuarios.cadastrar(
      nome: 'Visitante Domus',
      email: emailDemo,
      senha: senhaDemo,
      telefone: '83999990000',
    );

    // Ids fixos para a demonstração ser sempre igual.
    final porId = await acomodacoes.buscarPorIds([1, 2, 6]);
    if (porId.length < 3) return;
    final hoje = Datas.hoje();

    // Estadia concluída (mês passado).
    await reservas.inserir(Reserva.nova(
      usuarioId: usuario.id!,
      acomodacao: porId[2]!,
      checkIn: hoje.subtract(const Duration(days: 30)),
      checkOut: hoje.subtract(const Duration(days: 27)),
      numeroHospedes: 2,
    ));

    // Reserva futura (daqui a 2 semanas).
    await reservas.inserir(Reserva.nova(
      usuarioId: usuario.id!,
      acomodacao: porId[1]!,
      checkIn: hoje.add(const Duration(days: 14)),
      checkOut: hoje.add(const Duration(days: 17)),
      numeroHospedes: 2,
    ));

    await favoritos.adicionar(usuario.id!, 6);
    debugPrint('[Seed] Conta demo criada: $emailDemo / $senhaDemo');
  }
}
