import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/domus_logo.dart';
import '../../core/widgets/fundo_decorado.dart';
import '../../injecao.dart';
import '../../rotas.dart';

/// Tela de abertura com a logo e o slogan.
///
/// Enquanto a animação roda: abre o banco, executa o seed e recupera a
/// sessão salva. Depois vai para Home (logado) ou Login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Tempo mínimo de exibição, para a marca ser vista.
  static const _duracaoMinima = Duration(milliseconds: 2200);

  late final AnimationController _animacao = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  // Logo: aparece e cresce levemente (0% → 60% da animação).
  late final Animation<double> _logoOpacidade = CurvedAnimation(
    parent: _animacao,
    curve: const Interval(0, 0.5, curve: Curves.easeOut),
  );
  late final Animation<double> _logoEscala =
      Tween(begin: 0.8, end: 1.0).animate(CurvedAnimation(
    parent: _animacao,
    curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
  ));

  // Slogan: entra depois, subindo um pouco (45% → 100%).
  late final Animation<double> _sloganOpacidade = CurvedAnimation(
    parent: _animacao,
    curve: const Interval(0.45, 1, curve: Curves.easeOut),
  );
  late final Animation<Offset> _sloganPosicao =
      Tween(begin: const Offset(0, 0.4), end: Offset.zero)
          .animate(_sloganOpacidade);

  String? _erro;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    setState(() => _erro = null);
    try {
      final resultados = await Future.wait([
        Injecao.inicializar().then((_) => Injecao.sessao.restaurar()),
        Future<void>.delayed(_duracaoMinima),
      ]);
      final logado = resultados.first as bool;
      if (!mounted) return;
      Navigator.of(context)
          .pushReplacementNamed(logado ? Rotas.home : Rotas.login);
    } catch (e, pilha) {
      debugPrint('Erro ao iniciar: $e\n$pilha');
      if (mounted) setState(() => _erro = 'Não foi possível iniciar o app.');
    }
  }

  @override
  void dispose() {
    _animacao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;

    return Scaffold(
      body: FundoDecorado(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              FadeTransition(
                opacity: _logoOpacidade,
                child: ScaleTransition(
                  scale: _logoEscala,
                  child: const DomusLogo(altura: 190),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _sloganOpacidade,
                child: SlideTransition(
                  position: _sloganPosicao,
                  child: Text(
                    AppInfo.slogan,
                    textAlign: TextAlign.center,
                    style: texto.titleLarge?.copyWith(
                      color: AppColors.texto,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 4),
              if (_erro != null) ...[
                Text(_erro!, style: texto.bodyMedium),
                TextButton(
                  onPressed: _iniciar,
                  child: const Text('Tentar novamente'),
                ),
              ] else
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              const SizedBox(height: 20),
              Text(AppInfo.significado, style: texto.bodySmall),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
