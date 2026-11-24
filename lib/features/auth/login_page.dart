import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validadores.dart';
import '../../core/widgets/domus_logo.dart';
import '../../core/widgets/fundo_decorado.dart';
import '../../data/database/seed_database.dart';
import '../../data/repositories/repositorio_exception.dart';
import '../../injecao.dart';
import '../../rotas.dart';
import 'widgets/campo_senha.dart';
import 'widgets/mensagem_erro.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erro = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await Injecao.sessao.entrar(
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(Rotas.home, (_) => false);
    } on RepositorioException catch (e) {
      setState(() => _erro = e.mensagem);
    } catch (_) {
      setState(() => _erro = 'Algo deu errado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  /// Atalho (só em modo debug) para preencher a conta de demonstração.
  void _preencherDemo() {
    _emailCtrl.text = SeedDatabase.emailDemo;
    _senhaCtrl.text = SeedDatabase.senhaDemo;
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      body: FundoDecorado(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const DomusLogo(altura: 120),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        AppInfo.slogan,
                        textAlign: TextAlign.center,
                        style: texto.bodyLarge
                            ?.copyWith(color: AppColors.textoSecundario),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _CartaoFormulario(
                        children: [
                          Text('Bem-vindo de volta',
                              style: texto.headlineSmall),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Entre para encontrar sua próxima estadia.',
                            style: texto.bodyMedium
                                ?.copyWith(color: AppColors.textoSecundario),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            autofillHints: const [AutofillHints.email],
                            validator: Validadores.email,
                            decoration: const InputDecoration(
                              labelText: 'E-mail',
                              prefixIcon: Icon(Icons.mail_outline_rounded),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CampoSenha(
                            controller: _senhaCtrl,
                            validator: Validadores.senhaObrigatoria,
                            onFieldSubmitted: (_) => _entrar(),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          if (_erro != null) ...[
                            MensagemErro(_erro!),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          FilledButton(
                            onPressed: _carregando ? null : _entrar,
                            child: _carregando
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Não tem uma conta?', style: texto.bodyMedium),
                          TextButton(
                            onPressed: _carregando
                                ? null
                                : () => Navigator.of(context)
                                    .pushNamed(Rotas.cadastro),
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                      if (kDebugMode)
                        TextButton.icon(
                          onPressed: _preencherDemo,
                          icon: const Icon(Icons.bolt_rounded, size: 18),
                          label: const Text('Usar conta de demonstração'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textoSecundario,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cartão branco com sombra suave que agrupa o formulário.
class _CartaoFormulario extends StatelessWidget {
  const _CartaoFormulario({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaria.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
