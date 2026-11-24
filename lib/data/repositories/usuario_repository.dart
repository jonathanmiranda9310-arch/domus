import 'dart:isolate';

import '../../core/utils/senha_hash.dart';
import '../database/app_database.dart';
import '../models/usuario.dart';
import 'repositorio_exception.dart';

/// Acesso aos dados de usuários: cadastro, login e edição do perfil.
///
/// É a ÚNICA classe que lê ou grava as colunas de senha.
class UsuarioRepository {
  UsuarioRepository(this._db);

  final AppDatabase _db;

  /// Cria uma nova conta e retorna o usuário com `id`.
  ///
  /// Lança [EmailJaCadastradoException] se o e-mail já existir.
  Future<Usuario> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
  }) async {
    final db = await _db.database;
    final emailNormalizado = _normalizarEmail(email);

    if (await emailEmUso(emailNormalizado)) {
      throw const EmailJaCadastradoException();
    }

    final salt = SenhaHash.gerarSalt();
    final hash = await _calcularHash(senha, salt);

    final usuario = Usuario(
      nome: nome.trim(),
      email: emailNormalizado,
      telefone: _telefoneOuNulo(telefone),
      criadoEm: DateTime.now(),
    );

    final id = await db.insert(Tabelas.usuarios, {
      ...usuario.toMap(),
      'senha_hash': hash,
      'senha_salt': salt,
    });
    return usuario.copyWith(id: id);
  }

  /// Confere e-mail e senha. Lança [CredenciaisInvalidasException].
  ///
  /// A mensagem é a mesma para "e-mail não existe" e "senha errada",
  /// para não revelar quais e-mails têm conta.
  Future<Usuario> autenticar({
    required String email,
    required String senha,
  }) async {
    final linha = await _buscarLinhaPorEmail(_normalizarEmail(email));
    if (linha == null) throw const CredenciaisInvalidasException();

    final valida = await _verificarSenha(senha, linha);
    if (!valida) throw const CredenciaisInvalidasException();

    return Usuario.fromMap(linha);
  }

  Future<Usuario?> buscarPorId(int id) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.usuarios,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return linhas.isEmpty ? null : Usuario.fromMap(linhas.first);
  }

  /// Verifica se o e-mail já está em uso (ignorando o usuário [excetoId]).
  Future<bool> emailEmUso(String email, {int? excetoId}) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.usuarios,
      columns: ['id'],
      where: excetoId == null ? 'email = ?' : 'email = ? AND id != ?',
      whereArgs: [_normalizarEmail(email), if (excetoId != null) excetoId],
      limit: 1,
    );
    return linhas.isNotEmpty;
  }

  /// Atualiza nome, e-mail e telefone.
  Future<Usuario> atualizar(Usuario usuario) async {
    final id = usuario.id;
    if (id == null) throw const UsuarioNaoEncontradoException();

    final atualizado = usuario.copyWith(
      nome: usuario.nome.trim(),
      email: _normalizarEmail(usuario.email),
      telefone: _telefoneOuNulo(usuario.telefone),
      limparTelefone: _telefoneOuNulo(usuario.telefone) == null,
    );

    if (await emailEmUso(atualizado.email, excetoId: id)) {
      throw const EmailJaCadastradoException();
    }

    final db = await _db.database;
    final alteradas = await db.update(
      Tabelas.usuarios,
      {
        'nome': atualizado.nome,
        'email': atualizado.email,
        'telefone': atualizado.telefone,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    if (alteradas == 0) throw const UsuarioNaoEncontradoException();
    return atualizado;
  }

  /// Troca a senha, exigindo a senha atual.
  Future<void> alterarSenha({
    required int usuarioId,
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.usuarios,
      where: 'id = ?',
      whereArgs: [usuarioId],
      limit: 1,
    );
    if (linhas.isEmpty) throw const UsuarioNaoEncontradoException();

    if (!await _verificarSenha(senhaAtual, linhas.first)) {
      throw const SenhaAtualIncorretaException();
    }

    // Gera um salt novo a cada troca de senha.
    final salt = SenhaHash.gerarSalt();
    final hash = await _calcularHash(novaSenha, salt);
    await db.update(
      Tabelas.usuarios,
      {'senha_hash': hash, 'senha_salt': salt},
      where: 'id = ?',
      whereArgs: [usuarioId],
    );
  }

  // ---------------------------------------------------------------------------
  // Auxiliares privados
  // ---------------------------------------------------------------------------

  Future<Map<String, Object?>?> _buscarLinhaPorEmail(String email) async {
    final db = await _db.database;
    final linhas = await db.query(
      Tabelas.usuarios,
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return linhas.isEmpty ? null : linhas.first;
  }

  Future<bool> _verificarSenha(String senha, Map<String, Object?> linha) {
    final salt = linha['senha_salt'] as String;
    final hash = linha['senha_hash'] as String;
    // Roda em outra isolate para não travar a animação da tela.
    return Isolate.run(() => SenhaHash.verificar(senha, salt, hash));
  }

  Future<String> _calcularHash(String senha, String salt) =>
      Isolate.run(() => SenhaHash.gerarHash(senha, salt));

  static String _normalizarEmail(String email) => email.trim().toLowerCase();

  static String? _telefoneOuNulo(String? telefone) {
    final digitos = telefone?.replaceAll(RegExp(r'\D'), '') ?? '';
    return digitos.isEmpty ? null : digitos;
  }
}
