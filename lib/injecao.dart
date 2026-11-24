import 'package:intl/date_symbol_data_local.dart';

import 'data/database/app_database.dart';
import 'data/database/seed_database.dart';
import 'data/repositories/acomodacao_repository.dart';
import 'data/repositories/favorito_repository.dart';
import 'data/repositories/reserva_repository.dart';
import 'data/repositories/sessao_repository.dart';
import 'data/repositories/usuario_repository.dart';
import 'features/auth/sessao_controller.dart';
import 'features/favoritos/favoritos_controller.dart';

/// Ponto único de acesso aos repositórios e à sessão.
///
/// Exemplos de uso em qualquer tela:
/// ```dart
/// final lista = await Injecao.acomodacoes.buscar(filtro);
/// final ids = await Injecao.favoritos.listarIds(Injecao.sessao.usuarioId);
/// await Injecao.reservas.criar(usuarioId: ..., acomodacao: ..., ...);
/// ```
abstract final class Injecao {
  static final AppDatabase database = AppDatabase.instancia;

  static final UsuarioRepository usuarios = UsuarioRepository(database);
  static final AcomodacaoRepository acomodacoes =
      AcomodacaoRepository(database);
  static final ReservaRepository reservas =
      ReservaRepository(database, acomodacoes);
  static final FavoritoRepository favoritos = FavoritoRepository(database);

  static final SessaoController sessao =
      SessaoController(usuarios, SessaoRepository());

  /// Favoritos do usuário logado em memória (coração sincronizado).
  static final FavoritosController favoritosCtrl =
      FavoritosController(favoritos);

  static bool _inicializado = false;

  /// Prepara formatação pt_BR, abre o banco e roda o seed.
  /// Chamado uma vez pela Splash.
  static Future<void> inicializar() async {
    if (_inicializado) return;
    await initializeDateFormatting('pt_BR');
    await database.database;
    await SeedDatabase(
      acomodacoes: acomodacoes,
      usuarios: usuarios,
      reservas: reservas,
      favoritos: favoritos,
    ).executar();
    _inicializado = true;
  }
}
