import 'package:shared_preferences/shared_preferences.dart';

/// Guarda qual usuário está logado entre aberturas do app.
///
/// Salva apenas o id do usuário — nenhum dado sensível.
class SessaoRepository {
  static const _chaveUsuarioId = 'sessao_usuario_id';

  Future<void> salvar(int usuarioId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveUsuarioId, usuarioId);
  }

  Future<int?> lerUsuarioId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveUsuarioId);
  }

  Future<void> limpar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveUsuarioId);
  }
}
