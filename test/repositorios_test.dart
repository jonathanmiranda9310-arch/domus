import 'dart:io';

import 'package:domus/core/utils/datas.dart';
import 'package:domus/data/database/app_database.dart';
import 'package:domus/data/database/seed_database.dart';
import 'package:domus/data/models/models.dart';
import 'package:domus/data/repositories/acomodacao_repository.dart';
import 'package:domus/data/repositories/favorito_repository.dart';
import 'package:domus/data/repositories/repositorio_exception.dart';
import 'package:domus/data/repositories/reserva_repository.dart';
import 'package:domus/data/repositories/usuario_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Testa os repositórios com um banco SQLite em memória (via FFI),
/// usando o JSON real de `assets/`.
void main() {
  sqfliteFfiInit();

  late AppDatabase banco;
  late UsuarioRepository usuarios;
  late AcomodacaoRepository acomodacoes;
  late ReservaRepository reservas;
  late FavoritoRepository favoritos;

  setUp(() async {
    banco = AppDatabase(
      caminho: inMemoryDatabasePath,
      factory: databaseFactoryFfiNoIsolate,
    );
    usuarios = UsuarioRepository(banco);
    acomodacoes = AcomodacaoRepository(banco);
    reservas = ReservaRepository(banco, acomodacoes);
    favoritos = FavoritoRepository(banco);

    await SeedDatabase(
      acomodacoes: acomodacoes,
      usuarios: usuarios,
      reservas: reservas,
      favoritos: favoritos,
      carregarJson: () => File('assets/data/acomodacoes.json').readAsString(),
    ).executar();
  });

  tearDown(() => banco.fechar());

  group('Seed', () {
    test('carrega o JSON e cria a conta demo', () async {
      expect(await acomodacoes.contar(), 20);
      final demo = await usuarios.autenticar(
          email: SeedDatabase.emailDemo, senha: SeedDatabase.senhaDemo);
      expect(await reservas.listarProximas(demo.id!), hasLength(1));
      expect(await reservas.listarHistoricoEstadias(demo.id!), hasLength(1));
      expect(await favoritos.contar(demo.id!), 1);
    });

    test('não duplica ao rodar de novo', () async {
      await SeedDatabase(
        acomodacoes: acomodacoes,
        usuarios: usuarios,
        reservas: reservas,
        favoritos: favoritos,
        carregarJson: () => File('assets/data/acomodacoes.json').readAsString(),
      ).executar();
      expect(await acomodacoes.contar(), 20);
    });
  });

  group('UsuarioRepository', () {
    test('cadastra, autentica e nunca guarda a senha', () async {
      final u = await usuarios.cadastrar(
        nome: ' Ana Souza ',
        email: ' Ana@Email.com ',
        senha: 'minhaSenha',
        telefone: '(83) 98888-7777',
      );
      expect(u.id, isNotNull);
      expect(u.nome, 'Ana Souza');
      expect(u.email, 'ana@email.com');
      expect(u.telefone, '83988887777');

      final logado = await usuarios.autenticar(
          email: 'ANA@email.com', senha: 'minhaSenha');
      expect(logado.id, u.id);

      final db = await banco.database;
      final linha =
          (await db.query('usuarios', where: 'id = ?', whereArgs: [u.id]))
              .first;
      expect(linha['senha_hash'], isNot('minhaSenha'));
      expect(linha.values, isNot(contains('minhaSenha')));
    });

    test('e-mail duplicado e senha errada', () async {
      await usuarios.cadastrar(
          nome: 'Ana', email: 'ana@x.com', senha: '123456');
      expect(
        () => usuarios.cadastrar(
            nome: 'Outra', email: 'ANA@x.com', senha: '123456'),
        throwsA(isA<EmailJaCadastradoException>()),
      );
      expect(
        () => usuarios.autenticar(email: 'ana@x.com', senha: 'errada'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
      expect(
        () => usuarios.autenticar(email: 'naoexiste@x.com', senha: '123456'),
        throwsA(isA<CredenciaisInvalidasException>()),
      );
    });

    test('atualiza perfil e altera senha', () async {
      final u = await usuarios.cadastrar(
          nome: 'Ana', email: 'ana@x.com', senha: '123456');
      final atualizado = await usuarios
          .atualizar(u.copyWith(nome: 'Ana Lima', email: 'analima@x.com'));
      expect((await usuarios.buscarPorId(u.id!))!.nome, 'Ana Lima');
      expect(atualizado.email, 'analima@x.com');

      expect(
        () => usuarios.alterarSenha(
            usuarioId: u.id!, senhaAtual: 'errada', novaSenha: 'nova123'),
        throwsA(isA<SenhaAtualIncorretaException>()),
      );
      await usuarios.alterarSenha(
          usuarioId: u.id!, senhaAtual: '123456', novaSenha: 'nova123');
      expect(
          (await usuarios.autenticar(email: 'analima@x.com', senha: 'nova123'))
              .id,
          u.id);
    });
  });

  group('AcomodacaoRepository', () {
    test('busca por destino sem acento + filtros', () async {
      final jp =
          await acomodacoes.buscar(const FiltroBusca(destino: 'joao pessoa'));
      expect(jp, hasLength(5));

      final pousadasBaratas = await acomodacoes.buscar(const FiltroBusca(
        categoria: CategoriaAcomodacao.pousada,
        faixaPreco: FaixaPreco.de150a300,
      ));
      expect(pousadasBaratas, isNotEmpty);
      for (final a in pousadasBaratas) {
        expect(a.categoria, CategoriaAcomodacao.pousada);
        expect(a.valorDiaria, inInclusiveRange(150, 300));
      }

      final menorPreco = await acomodacoes
          .buscar(const FiltroBusca(ordenacao: OrdenacaoBusca.menorPreco));
      expect(menorPreco.first.valorDiaria, 75);

      final boas = await acomodacoes.buscar(const FiltroBusca(notaMinima: 4.7));
      expect(boas.every((a) => a.notaMedia >= 4.7), isTrue);

      final primeira = (await acomodacoes.buscarPorId(1))!;
      expect(primeira.fotos, isNotEmpty);
      expect(primeira.comodidades, contains(Comodidade.wifi));
    });
  });

  group('ReservaRepository', () {
    late Usuario usuario;
    late Acomodacao acomodacao;

    setUp(() async {
      usuario = await usuarios.cadastrar(
          nome: 'Ana', email: 'ana@x.com', senha: '123456');
      acomodacao = (await acomodacoes.buscarPorId(1))!; // diária 320, cap. 4
    });

    test('cria com valor total correto e lista em Próximas', () async {
      final inicio = Datas.hoje().add(const Duration(days: 5));
      final r = await reservas.criar(
        usuarioId: usuario.id!,
        acomodacao: acomodacao,
        checkIn: inicio,
        checkOut: inicio.add(const Duration(days: 3)),
        numeroHospedes: 2,
      );
      expect(r.noites, 3);
      expect(r.valorTotal, 960);

      final proximas = await reservas.listarProximas(usuario.id!);
      expect(proximas.single.acomodacao.nome, acomodacao.nome);
      expect(await reservas.listarConcluidas(usuario.id!), isEmpty);
    });

    test('valida datas, hóspedes e conflito', () async {
      final hoje = Datas.hoje();
      Future<Reserva> criar(DateTime i, DateTime f, [int h = 1]) =>
          reservas.criar(
            usuarioId: usuario.id!,
            acomodacao: acomodacao,
            checkIn: i,
            checkOut: f,
            numeroHospedes: h,
          );

      expect(() => criar(hoje.subtract(const Duration(days: 1)), hoje),
          throwsA(isA<ReservaInvalidaException>()));
      expect(() => criar(hoje, hoje), throwsA(isA<ReservaInvalidaException>()));
      expect(() => criar(hoje, hoje.add(const Duration(days: 1)), 9),
          throwsA(isA<ReservaInvalidaException>()));

      await criar(
          hoje.add(const Duration(days: 2)), hoje.add(const Duration(days: 5)));
      expect(
        () => criar(hoje.add(const Duration(days: 4)),
            hoje.add(const Duration(days: 6))),
        throwsA(isA<ReservaInvalidaException>()),
      );
      // Encostando no check-out (sem sobreposição) é permitido.
      await criar(
          hoje.add(const Duration(days: 5)), hoje.add(const Duration(days: 6)));
    });

    test('cancelar move para Concluídas como cancelada', () async {
      final inicio = Datas.hoje().add(const Duration(days: 10));
      final r = await reservas.criar(
        usuarioId: usuario.id!,
        acomodacao: acomodacao,
        checkIn: inicio,
        checkOut: inicio.add(const Duration(days: 2)),
        numeroHospedes: 1,
      );
      await reservas.cancelar(r.id!);

      expect(await reservas.listarProximas(usuario.id!), isEmpty);
      final concluidas = await reservas.listarConcluidas(usuario.id!);
      expect(concluidas.single.reserva.situacao(), SituacaoReserva.cancelada);
      expect(await reservas.listarHistoricoEstadias(usuario.id!), isEmpty);
      expect(() => reservas.cancelar(r.id!),
          throwsA(isA<ReservaInvalidaException>()));
    });
  });

  group('FavoritoRepository', () {
    test('alternar adiciona e remove', () async {
      final u = await usuarios.cadastrar(
          nome: 'Ana', email: 'ana@x.com', senha: '123456');
      expect(await favoritos.alternar(u.id!, 3), isTrue);
      expect(await favoritos.alternar(u.id!, 5), isTrue);
      expect(await favoritos.listarIds(u.id!), {3, 5});
      expect((await favoritos.listarAcomodacoes(u.id!)).first.id, 5);
      expect(await favoritos.alternar(u.id!, 3), isFalse);
      expect(await favoritos.listarIds(u.id!), {5});
    });
  });
}
