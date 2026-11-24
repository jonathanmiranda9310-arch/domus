import 'package:flutter/foundation.dart';

import '../../data/repositories/favorito_repository.dart';

/// Guarda em memória os ids favoritos do usuário logado, para que o
/// coração fique sincronizado entre Explorar, Detalhes e Favoritos.
///
/// Uso: `Injecao.favoritosCtrl.isFavorito(id)` e
/// `Injecao.favoritosCtrl.alternar(id)` dentro de um `ListenableBuilder`.
class FavoritosController extends ChangeNotifier {
  FavoritosController(this._repositorio);

  final FavoritoRepository _repositorio;

  /// Ordem de inserção = do mais antigo para o mais recente.
  Set<int> _ids = <int>{};
  int? _usuarioId;

  bool isFavorito(int acomodacaoId) => _ids.contains(acomodacaoId);

  /// Ids do mais recente para o mais antigo.
  List<int> get idsRecentesPrimeiro => _ids.toList().reversed.toList();

  int get total => _ids.length;

  Future<void> carregar(int usuarioId) async {
    _usuarioId = usuarioId;
    _ids = (await _repositorio.listarIds(usuarioId)).toSet();
    notifyListeners();
  }

  /// Liga/desliga o favorito. Atualiza a tela na hora e desfaz se o
  /// banco falhar. Retorna o novo estado.
  Future<bool> alternar(int acomodacaoId) async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return false;

    final favoritar = !_ids.contains(acomodacaoId);
    favoritar ? _ids.add(acomodacaoId) : _ids.remove(acomodacaoId);
    notifyListeners();

    try {
      if (favoritar) {
        await _repositorio.adicionar(usuarioId, acomodacaoId);
      } else {
        await _repositorio.remover(usuarioId, acomodacaoId);
      }
    } catch (_) {
      favoritar ? _ids.remove(acomodacaoId) : _ids.add(acomodacaoId);
      notifyListeners();
      rethrow;
    }
    return favoritar;
  }

  /// Chamado no logout.
  void limpar() {
    _ids = <int>{};
    _usuarioId = null;
    notifyListeners();
  }
}
