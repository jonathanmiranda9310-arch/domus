import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Nomes das tabelas (evita erro de digitação nos repositórios).
abstract final class Tabelas {
  static const usuarios = 'usuarios';
  static const acomodacoes = 'acomodacoes';
  static const reservas = 'reservas';
  static const favoritos = 'favoritos';
}

/// Banco SQLite local do Domus.
///
/// Uso normal (no app): `AppDatabase.instancia`.
/// Nos testes: `AppDatabase(caminho: inMemoryDatabasePath, factory: databaseFactoryFfi)`.
class AppDatabase {
  AppDatabase({String? caminho, DatabaseFactory? factory})
      : _caminho = caminho,
        _factory = factory;

  /// Instância única usada pelo app.
  static final AppDatabase instancia = AppDatabase();

  static const String nomeArquivo = 'domus.db';

  /// Aumente este número ao alterar o esquema e trate em [_migrar].
  static const int versao = 1;

  final String? _caminho;
  final DatabaseFactory? _factory;
  Future<Database>? _abrindo;

  /// Abre o banco na primeira chamada e reaproveita nas seguintes.
  Future<Database> get database => _abrindo ??= _abrir();

  Future<Database> _abrir() async {
    final factory = _factory ?? databaseFactory;
    final caminho =
        _caminho ?? join(await factory.getDatabasesPath(), nomeArquivo);

    return factory.openDatabase(
      caminho,
      options: OpenDatabaseOptions(
        version: versao,
        // O SQLite vem com chaves estrangeiras desligadas por padrão.
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _criarTabelas,
        onUpgrade: _migrar,
      ),
    );
  }

  Future<void> _criarTabelas(Database db, int versao) async {
    final batch = db.batch();

    // Senha: apenas hash + salt (ver core/utils/senha_hash.dart).
    batch.execute('''
      CREATE TABLE ${Tabelas.usuarios} (
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        nome        TEXT    NOT NULL,
        email       TEXT    NOT NULL UNIQUE,
        telefone    TEXT,
        senha_hash  TEXT    NOT NULL,
        senha_salt  TEXT    NOT NULL,
        criado_em   TEXT    NOT NULL
      )
    ''');

    // fotos e comodidades ficam como texto JSON: ["url1", "url2"].
    // termo_busca guarda nome/bairro/cidade/UF sem acento, para a busca
    // por destino funcionar com "joao pessoa" ou "João Pessoa".
    batch.execute('''
      CREATE TABLE ${Tabelas.acomodacoes} (
        id                 INTEGER PRIMARY KEY AUTOINCREMENT,
        nome               TEXT    NOT NULL,
        categoria          TEXT    NOT NULL
                           CHECK (categoria IN ('hotel', 'pousada', 'quarto')),
        descricao          TEXT    NOT NULL DEFAULT '',
        endereco           TEXT    NOT NULL DEFAULT '',
        bairro             TEXT    NOT NULL DEFAULT '',
        cidade             TEXT    NOT NULL,
        estado             TEXT    NOT NULL,
        valor_diaria       REAL    NOT NULL CHECK (valor_diaria >= 0),
        nota_media         REAL    NOT NULL DEFAULT 0,
        total_avaliacoes   INTEGER NOT NULL DEFAULT 0,
        capacidade_maxima  INTEGER NOT NULL DEFAULT 2,
        fotos              TEXT    NOT NULL DEFAULT '[]',
        comodidades        TEXT    NOT NULL DEFAULT '[]',
        termo_busca        TEXT    NOT NULL DEFAULT ''
      )
    ''');

    // Datas no formato yyyy-MM-dd, para comparar direto no SQL.
    batch.execute('''
      CREATE TABLE ${Tabelas.reservas} (
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id       INTEGER NOT NULL
                         REFERENCES ${Tabelas.usuarios}(id) ON DELETE CASCADE,
        acomodacao_id    INTEGER NOT NULL
                         REFERENCES ${Tabelas.acomodacoes}(id),
        check_in         TEXT    NOT NULL,
        check_out        TEXT    NOT NULL,
        numero_hospedes  INTEGER NOT NULL CHECK (numero_hospedes > 0),
        valor_diaria     REAL    NOT NULL,
        valor_total      REAL    NOT NULL,
        status           TEXT    NOT NULL DEFAULT 'ativa'
                         CHECK (status IN ('ativa', 'cancelada')),
        criado_em        TEXT    NOT NULL,
        CHECK (check_out > check_in)
      )
    ''');

    batch.execute('''
      CREATE TABLE ${Tabelas.favoritos} (
        usuario_id     INTEGER NOT NULL
                       REFERENCES ${Tabelas.usuarios}(id) ON DELETE CASCADE,
        acomodacao_id  INTEGER NOT NULL
                       REFERENCES ${Tabelas.acomodacoes}(id) ON DELETE CASCADE,
        criado_em      TEXT    NOT NULL,
        PRIMARY KEY (usuario_id, acomodacao_id)
      )
    ''');

    // Índices para as consultas mais comuns.
    batch.execute('CREATE INDEX idx_reservas_usuario '
        'ON ${Tabelas.reservas}(usuario_id, check_out)');
    batch.execute('CREATE INDEX idx_acomodacoes_categoria '
        'ON ${Tabelas.acomodacoes}(categoria)');

    await batch.commit(noResult: true);
  }

  /// Migrações futuras. Exemplo:
  /// ```dart
  /// if (versaoAntiga < 2) {
  ///   await db.execute('ALTER TABLE reservas ADD COLUMN observacao TEXT');
  /// }
  /// ```
  Future<void> _migrar(Database db, int versaoAntiga, int versaoNova) async {}

  /// Fecha a conexão (usado principalmente nos testes).
  Future<void> fechar() async {
    final db = await _abrindo;
    await db?.close();
    _abrindo = null;
  }
}
