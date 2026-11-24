import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/telefone_input_formatter.dart';
import '../../core/utils/validadores.dart';
import '../../core/widgets/domus_logo.dart';
import '../../core/widgets/fundo_decorado.dart';
import '../../data/repositories/repositorio_exception.dart';
import '../../injecao.dart';
import '../../rotas.dart';
import 'widgets/campo_senha.dart';
import 'widgets/mensagem_erro.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    for (final c in [
      _nomeCtrl,
      _emailCtrl,
      _telefoneCtrl,
      _senhaCtrl,
      _confirmarCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _cadastrar() async {
    FocusScope.of(context).unfocus();
    setState(() => _erro = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);
    try {
      await Injecao.sessao.cadastrar(
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
        telefone: _telefoneCtrl.text,
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

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    const espaco = SizedBox(height: AppSpacing.md);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: FundoDecorado(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, kToolbarHeight, AppSpacing.lg, AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: DomusMarca(altura: 36),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Criar conta', style: texto.headlineMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Leva menos de um minuto. ${AppInfo.slogan}',
                      style: texto.bodyLarge
                          ?.copyWith(color: AppColors.textoSecundario),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nomeCtrl,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: Validadores.nome,
                      decoration: const InputDecoration(
                        labelText: 'Nome completo',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    espaco,
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
                    espaco,
                    TextFormField(
                      controller: _telefoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      inputFormatters: [TelefoneInputFormatter()],
                      validator: Validadores.telefoneOpcional,
                      decoration: const InputDecoration(
                        labelText: 'Telefone (opcional)',
                        hintText: '(83) 99999-9999',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    espaco,
                    CampoSenha(
                      controller: _senhaCtrl,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.newPassword],
                      validator: Validadores.novaSenha,
                    ),
                    espaco,
                    CampoSenha(
                      controller: _confirmarCtrl,
                      rotulo: 'Confirmar senha',
                      autofillHints: const [AutofillHints.newPassword],
                      validator:
                          Validadores.confirmarSenha(() => _senhaCtrl.text),
                      onFieldSubmitted: (_) => _cadastrar(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_erro != null) ...[
                      MensagemErro(_erro!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    FilledButton(
                      onPressed: _carregando ? null : _cadastrar,
                      child: _carregando
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar conta'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('Já tem uma conta?', style: texto.bodyMedium),
                        TextButton(
                          onPressed: _carregando
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Entrar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
