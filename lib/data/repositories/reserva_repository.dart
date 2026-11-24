import 'package:sqflite/sqflite.dart';

import '../../core/utils/datas.dart';
import '../database/app_database.dart';
import '../models/acomodacao.dart';
import '../models/reserva.dart';
import 'acomodacao_repository.dart';
import 'repositorio_exception.dart';

/// Criação, listagem e cancelamento de reservas.
///
/// Regras:
/// - valorTotal = valorDiaria × noites (checkOut − checkIn);
/// - "Próximas"  = ativas com check-out a partir de hoje
///   (inclui as que começam hoje ou depois e as em andamento);
/// - "Concluídas" = ativas com check-out já passado + canceladas.
class ReservaRepository {
  ReservaRepository(this._db, this._acomodacoes);

  final AppDatabase _db;
  final AcomodacaoRepository _acomodacoes;

  /// Cria uma reserva após validar datas e número de hóspedes.
  ///
  /// Lança [ReservaInvalidaException] com a mensagem para a tela.
  Future<Reserva> criar({
    required int usuarioId,
    required Acomodacao acomodacao,
    required DateTime checkIn,
    required DateTime checkOut,
    required int numeroHospedes,
  }) async {
    final hoje = Datas.hoje();
    if (Datas.antesDe(checkIn, hoje)) {
      throw const ReservaInvalidaException(
          'A data de check-in não pode estar no passado.');
    }
    if (Datas.calcularNoites(checkIn, checkOut) < 1) {
      throw const ReservaInvalidaException(
          'O check-out deve ser pelo menos 1 dia depois do check-in.');
    }
    if (numeroHospedes < 1) {
      throw const ReservaInvalidaException('Informe ao menos 1 hóspede.');
    }
    if (numeroHospedes > acomodacao.capacidadeMaxima) {
      throw ReservaInvalidaException(
          'Esta acomodação comporta até ${acomodacao.capacidadeMaxima} '
          '${acomodacao.capacidadeMaxima == 1 ? 'hóspede' : 'hóspedes'}.');
    }
    if (await _temConflito(usuarioId, acomodacao.id!, checkIn, checkOut)) {
      throw const ReservaInvalidaException(
          'Você já tem uma reserva nesta acomodação nessas datas.');
    }

    return inserir(Reserva.nova(
      usuarioId: usuarioId,
      acomodacao: acomodacao,
      checkIn: checkIn,
      checkOut: checkOut,
      numeroHospedes: numeroHospedes,
    ));
  }

  /// Grava a reserva sem validações (uso interno / seed).
  Future<Reserva> inserir(Reserva reserva) async {
    final db = await _db.database;
    final id = await db.insert(Tabelas.reservas, reserva.toMap());
    return reserva.copyWith(id: id);
  }

  Future<ReservaComAcomodacao?> buscarPorId(int reservaId) async {
    final lista = await _listar('id = ?', [reservaId], 'id');
    return lista.isEmpty ? null : lista.first;
  }

  /// Aba "Próximas": da mais próxima para a mais distante.
  Future<List<ReservaComAcomodacao>> listarProximas(int usuarioId) => _listar(
        "usuario_id = ? AND status = 'ativa' AND check_out >= ?",
        [usuarioId, Datas.paraIso(Datas.hoje())],
        'check_in ASC',
      );

  /// Aba "Concluídas": da mais recente para a mais antiga.
  /// Inclui as canceladas (use `reserva.situacao()` para o badge).
  Future<List<ReservaComAcomodacao>> listarConcluidas(int usuarioId) => _listar(
        "usuario_id = ? AND (status = 'cancelada' OR check_out < ?)",
        [usuarioId, Datas.paraIso(Datas.hoje())],
        'check_in DESC',
      );

  /// Histórico de estadias do Perfil: só as concluídas de fato
  /// (sem as canceladas).
  Future<List<ReservaComAcomodacao>> listarHistoricoEstadias(int usuarioId) =>
      _listar(
        "usuario_id = ? AND status = 'ativa' AND check_out < ?",
        [usuarioId, Datas.paraIso(Datas.hoje())],
        'check_in DESC',
      );

  /// Quantidade de reservas na aba "Próximas" (para o resumo do Perfil).
  Future<int> contarProximas(int usuarioId) async {
    final db = await _db.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM ${Tabelas.reservas} '
      "WHERE usuario_id = ? AND status = 'ativa' AND check_out >= ?",
      [usuarioId, Datas.paraIso(Datas.hoje())],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Cancela uma reserva que ainda não começou.
  Future<void> cancelar(int reservaId) async {
    final item = await buscarPorId(reservaId);
    if (item == null) {
      throw const ReservaInvalidaException('Reserva não encontrada.');
    }
    if (!item.reserva.podeCancelar()) {
      throw const ReservaInvalidaException(
          'Só é possível cancelar reservas que ainda não começaram.');
    }
    final db = await _db.database;
    await db.update(
      Tabelas.reservas,
      {'status': StatusReserva.cancelada.name},
      where: 'id = ?',
      whereArgs: [reservaId],
    );
  }

  // ---------------------------------------------------------------------------
  // Auxiliares privados
  // ---------------------------------------------------------------------------

  /// Busca as reservas e "anexa" a acomodação de cada uma
  /// (uma consulta para reservas + uma para acomodações).
  Future<List<ReservaComAcomodacao>> _listar(
    String where,
    List<Object?> args,
    String orderBy,
  ) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.reservas,
      where: where,
      whereArgs: args,
      orderBy: orderBy,
    );
    final reservas = linhas.map(Reserva.fromMap).toList();
    final acomodacoes =
        await _acomodacoes.buscarPorIds(reservas.map((r) => r.acomodacaoId));

    return [
      for (final r in reservas)
        if (acomodacoes[r.acomodacaoId] != null)
          ReservaComAcomodacao(
            reserva: r,
            acomodacao: acomodacoes[r.acomodacaoId]!,
          ),
    ];
  }

  /// Existe outra reserva ativa do mesmo usuário, na mesma acomodação,
  /// com datas que se sobrepõem?
  Future<bool> _temConflito(
    int usuarioId,
    int acomodacaoId,
    DateTime checkIn,
    DateTime checkOut,
  ) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.reservas,
      columns: ['id'],
      where: "usuario_id = ? AND acomodacao_id = ? AND status = 'ativa' "
          'AND check_in < ? AND check_out > ?',
      whereArgs: [
        usuarioId,
        acomodacaoId,
        Datas.paraIso(checkOut),
        Datas.paraIso(checkIn),
      ],
      limit: 1,
    );
    return linhas.isNotEmpty;
  }
}
