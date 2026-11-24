import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/reserva.dart';
import '../../injecao.dart';
import '../../rotas.dart';
import 'widgets/alterar_senha_sheet.dart';
import 'widgets/dados_pessoais_card.dart';
import 'widgets/historico_estadias.dart';
import 'widgets/perfil_cabecalho.dart';

/// Perfil do usuário: resumo, dados pessoais, segurança, histórico
/// de estadias e botão de sair.
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  late Future<(ResumoPerfil, List<ReservaComAcomodacao>)> _dados;

  @override
  void initState() {
    super.initState();
    _dados = _carregar();
  }

  Future<(ResumoPerfil, List<ReservaComAcomodacao>)> _carregar() async {
    final id = Injecao.sessao.usuarioId;
    final resultados = await Future.wait([
      Injecao.reservas.listarHistoricoEstadias(id),
      Injecao.reservas.contarProximas(id),
      Injecao.favoritos.contar(id),
    ]);
    final historico = resultados[0] as List<ReservaComAcomodacao>;
    return (
      ResumoPerfil(
        estadias: historico.length,
        proximas: resultados[1] as int,
        favoritos: resultados[2] as int,
      ),
      historico,
    );
  }

  Future<void> _recarregar() async {
    setState(() => _dados = _carregar());
    await _dados;
  }

  Future<void> _alterarSenha() async {
    final alterou = await AlterarSenhaSheet.abrir(context);
    if (alterou == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso.')),
      );
    }
  }

  Future<void> _sair() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta?'),
        content: const Text(
            'Você precisará entrar novamente para ver suas reservas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.erro),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true || !mounted) return;

    final navegador = Navigator.of(context);
    Injecao.favoritosCtrl.limpar();
    await Injecao.sessao.sair();
    navegador.pushNamedAndRemoveUntil(Rotas.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: ListenableBuilder(
        listenable: Injecao.sessao,
        builder: (context, _) {
          final usuario = Injecao.sessao.usuario;
          // Durante o logout o usuário vira null antes da navegação.
          if (usuario == null) return const SizedBox.shrink();

          return FutureBuilder(
            future: _dados,
            builder: (context, snapshot) {
              final (resumo, historico) = snapshot.data ?? (null, null);

              return RefreshIndicator(
                onRefresh: _recarregar,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md,
                      AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
                  children: [
                    PerfilCabecalho(usuario: usuario, resumo: resumo),
                    const _Secao('Dados pessoais'),
                    DadosPessoaisCard(
                      // Recria o formulário quando os dados salvos mudam.
                      key: ValueKey(usuario),
                      usuario: usuario,
                    ),
                    const _Secao('Segurança'),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.lock_reset_rounded,
                            color: AppColors.primaria),
                        title: Text('Alterar senha', style: texto.titleSmall),
                        subtitle: const Text(
                            'Sua senha é guardada com criptografia (hash).'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _alterarSenha,
                      ),
                    ),
                    const _Secao('Histórico de estadias'),
                    if (snapshot.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (snapshot.hasError)
                      const Text('Não foi possível carregar o histórico.')
                    else
                      HistoricoEstadias(estadias: historico ?? const []),
                    const SizedBox(height: AppSpacing.xl),
                    OutlinedButton.icon(
                      onPressed: _sair,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair da conta'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.erro,
                        side: const BorderSide(color: AppColors.erroClaro),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Título de seção da página.
class _Secao extends StatelessWidget {
  const _Secao(this.titulo);

  final String titulo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, AppSpacing.lg, 4, AppSpacing.sm),
      child: Text(titulo, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
