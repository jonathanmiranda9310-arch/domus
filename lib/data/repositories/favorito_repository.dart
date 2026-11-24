import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../models/acomodacao.dart';
import '../models/favorito.dart';

/// Acomodações salvas pelo usuário (coração nos cards / detalhes).
class FavoritoRepository {
  FavoritoRepository(this._db);

  final AppDatabase _db;

  /// Acomodações favoritas, da salva mais recentemente para a mais antiga.
  Future<List<Acomodacao>> listarAcomodacoes(int usuarioId) async {
    final db = await _db.database;
    final linhas = await db.rawQuery('''
      SELECT a.*
      FROM ${Tabelas.favoritos} f
      JOIN ${Tabelas.acomodacoes} a ON a.id = f.acomodacao_id
      WHERE f.usuario_id = ?
      ORDER BY f.criado_em DESC
    ''', [usuarioId]);
    return linhas.map(Acomodacao.fromMap).toList();
  }

  /// Ids das favoritas — útil para pintar o coração na lista da Home
  /// sem fazer uma consulta por card.
  Future<Set<int>> listarIds(int usuarioId) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.favoritos,
      columns: ['acomodacao_id'],
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'criado_em ASC',
    );
    return linhas.map((l) => l['acomodacao_id'] as int).toSet();
  }

  Future<bool> isFavorito(int usuarioId, int acomodacaoId) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.favoritos,
      where: 'usuario_id = ? AND acomodacao_id = ?',
      whereArgs: [usuarioId, acomodacaoId],
      limit: 1,
    );
    return linhas.isNotEmpty;
  }

  Future<void> adicionar(int usuarioId, int acomodacaoId) async {
    final db = await _db.database;
    await db.insert(
      Tabelas.favoritos,
      Favorito(
        usuarioId: usuarioId,
        acomodacaoId: acomodacaoId,
        criadoEm: DateTime.now(),
      ).toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore, // já favoritado: ignora
    );
  }

  Future<void> remover(int usuarioId, int acomodacaoId) async {
    final db = await _db.database;
    await db.delete(
      Tabelas.favoritos,
      where: 'usuario_id = ? AND acomodacao_id = ?',
      whereArgs: [usuarioId, acomodacaoId],
    );
  }

  /// Liga/desliga o favorito. Retorna o novo estado (`true` = favoritado).
  Future<bool> alternar(int usuarioId, int acomodacaoId) async {
    if (await isFavorito(usuarioId, acomodacaoId)) {
      await remover(usuarioId, acomodacaoId);
      return false;
    }
    await adicionar(usuarioId, acomodacaoId);
    return true;
  }

  Future<int> contar(int usuarioId) async {
    final db = await _db.database;
    final resultado = await db.rawQuery(
      'SELECT COUNT(*) FROM ${Tabelas.favoritos} WHERE usuario_id = ?',
      [usuarioId],
    );
    return Sqflite.firstIntValue(resultado) ?? 0;
  }
}
