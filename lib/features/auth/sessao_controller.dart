import 'package:flutter/foundation.dart';

import '../../data/models/usuario.dart';
import '../../data/repositories/sessao_repository.dart';
import '../../data/repositories/usuario_repository.dart';

/// Estado global de autenticação: quem está logado.
///
/// Qualquer tela pode ler o usuário atual com `Injecao.sessao.usuario`
/// ou reagir a mudanças com
/// `ListenableBuilder(listenable: Injecao.sessao, builder: ...)`.
///
/// Erros de regra (e-mail duplicado, senha errada...) são lançados como
/// `RepositorioException` para a tela exibir `e.mensagem`.
class SessaoController extends ChangeNotifier {
  SessaoController(this._usuarios, this._sessao);

  final UsuarioRepository _usuarios;
  final SessaoRepository _sessao;

  Usuario? _usuario;

  /// Usuário logado (ou `null`).
  Usuario? get usuario => _usuario;

  bool get logado => _usuario != null;

  /// Id do usuário logado. Use apenas em telas que exigem login.
  int get usuarioId {
    final id = _usuario?.id;
    if (id == null) throw StateError('Nenhum usuário logado.');
    return id;
  }

  /// Tenta recuperar a sessão salva. Retorna `true` se havia alguém logado.
  Future<bool> restaurar() async {
    final id = await _sessao.lerUsuarioId();
    if (id == null) return false;

    final usuario = await _usuarios.buscarPorId(id);
    if (usuario == null) {
      // Sessão aponta para um usuário que não existe mais.
      await _sessao.limpar();
      return false;
    }
    _definir(usuario);
    return true;
  }

  Future<void> entrar({required String email, required String senha}) async {
    final usuario = await _usuarios.autenticar(email: email, senha: senha);
    await _sessao.salvar(usuario.id!);
    _definir(usuario);
  }

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
    String? telefone,
  }) async {
    final usuario = await _usuarios.cadastrar(
      nome: nome,
      email: email,
      senha: senha,
      telefone: telefone,
    );
    await _sessao.salvar(usuario.id!);
    _definir(usuario);
  }

  Future<void> atualizarPerfil({
    required String nome,
    required String email,
    String? telefone,
  }) async {
    final atual = _usuario;
    if (atual == null) throw StateError('Nenhum usuário logado.');
    final atualizado = await _usuarios.atualizar(
      atual.copyWith(nome: nome, email: email, telefone: telefone ?? ''),
    );
    _definir(atualizado);
  }

  Future<void> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) {
    return _usuarios.alterarSenha(
      usuarioId: usuarioId,
      senhaAtual: senhaAtual,
      novaSenha: novaSenha,
    );
  }

  Future<void> sair() async {
    await _sessao.limpar();
    _definir(null);
  }

  void _definir(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }
}
