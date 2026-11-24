import 'package:sqflite/sqflite.dart';

import '../../core/utils/texto.dart';
import '../database/app_database.dart';
import '../models/acomodacao.dart';
import '../models/filtro_busca.dart';

/// Consulta de acomodações (tela Explorar e Detalhes).
class AcomodacaoRepository {
  AcomodacaoRepository(this._db);

  final AppDatabase _db;

  /// Todas as acomodações, das mais bem avaliadas para as demais.
  Future<List<Acomodacao>> listarTodas() => buscar(const FiltroBusca());

  Future<Acomodacao?> buscarPorId(int id) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.acomodacoes,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return linhas.isEmpty ? null : Acomodacao.fromMap(linhas.first);
  }

  /// Busca com filtros opcionais (destino, categoria, preço, nota,
  /// hóspedes) e ordenação.
  ///
  /// Obs.: as datas do filtro não bloqueiam resultados — o app não
  /// controla estoque de quartos; elas servem para calcular o total.
  Future<List<Acomodacao>> buscar(FiltroBusca filtro) async {
    final db = await _db.database;
    final condicoes = <String>[];
    final argumentos = <Object?>[];

    final destino = filtro.destino?.trim() ?? '';
    if (destino.isNotEmpty) {
      condicoes.add('termo_busca LIKE ?');
      argumentos.add('%${Texto.normalizar(destino)}%');
    }
    if (filtro.categoria != null) {
      condicoes.add('categoria = ?');
      argumentos.add(filtro.categoria!.name);
    }
    final faixa = filtro.faixaPreco;
    if (faixa?.minimo != null) {
      condicoes.add('valor_diaria >= ?');
      argumentos.add(faixa!.minimo);
    }
    if (faixa?.maximo != null) {
      condicoes.add('valor_diaria <= ?');
      argumentos.add(faixa!.maximo);
    }
    if (filtro.notaMinima != null) {
      condicoes.add('nota_media >= ?');
      argumentos.add(filtro.notaMinima);
    }
    if (filtro.hospedes != null) {
      condicoes.add('capacidade_maxima >= ?');
      argumentos.add(filtro.hospedes);
    }

    final linhas = await db.query(
      Tabelas.acomodacoes,
      where: condicoes.isEmpty ? null : condicoes.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: switch (filtro.ordenacao) {
        OrdenacaoBusca.menorPreco => 'valor_diaria ASC, nota_media DESC',
        OrdenacaoBusca.maiorNota => 'nota_media DESC, total_avaliacoes DESC',
        // "Relevância": nota ponderada pelo número de avaliações.
        OrdenacaoBusca.relevancia =>
          'nota_media * MIN(total_avaliacoes, 200) DESC, nota_media DESC',
      },
    );
    return linhas.map(Acomodacao.fromMap).toList();
  }

  /// Lista de destinos para sugestões na barra de busca.
  /// Ex.: ["João Pessoa - PB", "Natal - RN", ...]
  Future<List<String>> listarDestinos() async {
    final db = await _db.database;
    final linhas = await db.rawQuery(
      'SELECT DISTINCT cidade, estado FROM ${Tabelas.acomodacoes} '
      'ORDER BY cidade',
    );
    return linhas.map((l) => '${l['cidade']} - ${l['estado']}').toList();
  }

  Future<int> contar() async {
    final db = await _db.database;
    final resultado =
        await db.rawQuery('SELECT COUNT(*) FROM ${Tabelas.acomodacoes}');
    return Sqflite.firstIntValue(resultado) ?? 0;
  }

  /// Busca várias acomodações pelos ids (usado pelos outros repositórios).
  Future<Map<int, Acomodacao>> buscarPorIds(Iterable<int> ids) async {
    final lista = ids.toSet().toList();
    if (lista.isEmpty) return {};
    final db = await _db.database;
    final marcadores = List.filled(lista.length, '?').join(', ');
    final linhas = await db.query(
      Tabelas.acomodacoes,
      where: 'id IN ($marcadores)',
      whereArgs: lista,
    );
    return {
      for (final l in linhas) l['id'] as int: Acomodacao.fromMap(l),
    };
  }

  /// Insere várias acomodações de uma vez (usado pelo seed).
  /// Ids que já existem são ignorados, preservando reservas e favoritos.
  Future<void> inserirVarias(List<Acomodacao> acomodacoes) async {
    final db = await _db.database;
    final batch = db.batch();
    for (final a in acomodacoes) {
      batch.insert(
        Tabelas.acomodacoes,
        {...a.toMap(), 'termo_busca': _termoBusca(a)},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  static String _termoBusca(Acomodacao a) => Texto.normalizar(
        [a.nome, a.bairro, a.cidade, a.estado, a.categoria.rotulo].join(' '),
      );
}
