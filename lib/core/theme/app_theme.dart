import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Medidas reutilizáveis de espaçamento e arredondamento.
///
/// Padronizar estes valores deixa as telas com o mesmo "respiro",
/// mesmo sendo feitas por pessoas diferentes.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Padding horizontal padrão das telas.
  static const EdgeInsets tela = EdgeInsets.symmetric(horizontal: md);
}

abstract final class AppRadius {
  /// Raio padrão dos cards (requisito do projeto: 16px).
  static const double card = 16;

  /// Raio de botões e campos de texto.
  static const double controle = 12;

  /// Raio "pílula" para chips e badges.
  static const double pilula = 100;

  static const BorderRadius cardBorder =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius controleBorder =
      BorderRadius.all(Radius.circular(controle));
}

/// Tema global do aplicativo (Material 3).
abstract final class AppTheme {
  static ThemeData get claro {
    // Esquema de cores gerado a partir da primária e ajustado à paleta Domus.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaria,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.primaria,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primariaClara,
      onPrimaryContainer: AppColors.primariaEscura,
      secondary: AppColors.secundaria,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secundariaClara,
      surface: AppColors.card,
      onSurface: AppColors.texto,
      onSurfaceVariant: AppColors.textoSecundario,
      outline: AppColors.borda,
      outlineVariant: AppColors.borda,
      error: AppColors.erro,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.fundo,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,

      // ---------------- AppBar: limpa, sem sombra, mesma cor do fundo
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.fundo,
        foregroundColor: AppColors.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
      ),

      // ---------------- Cards: brancos, 16px, sombra praticamente nula
      cardTheme: const CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias, // garante que a foto respeite o raio
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
          side: BorderSide(color: AppColors.borda),
        ),
      ),

      // ---------------- Botão principal ("Reservar agora", "Entrar")
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.borda,
          disabledForegroundColor: AppColors.textoDesabilitado,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controleBorder,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaria,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controleBorder,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),

      // ---------------- Botão secundário ("Cancelar reserva", "Sair")
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaria,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.borda),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.controleBorder,
          ),
          textStyle: textTheme.labelLarge?.copyWith(fontSize: 16),
        ),
      ),

      // ---------------- Links ("Criar conta", "Ver detalhes")
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaria,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ---------------- Campos de formulário (login, cadastro, perfil, busca)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textoDesabilitado),
        labelStyle:
            textTheme.bodyMedium?.copyWith(color: AppColors.textoSecundario),
        prefixIconColor: AppColors.textoSecundario,
        suffixIconColor: AppColors.textoSecundario,
        border: _bordaCampo(AppColors.borda),
        enabledBorder: _bordaCampo(AppColors.borda),
        focusedBorder: _bordaCampo(AppColors.primaria, largura: 1.5),
        errorBorder: _bordaCampo(AppColors.erro),
        focusedErrorBorder: _bordaCampo(AppColors.erro, largura: 1.5),
      ),

      // ---------------- Chips de filtro (Hotéis, Pousadas, Quartos)
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.primaria,
        disabledColor: AppColors.borda,
        checkmarkColor: Colors.white,
        labelStyle: textTheme.labelLarge?.copyWith(color: AppColors.texto),
        secondaryLabelStyle:
            textTheme.labelLarge?.copyWith(color: Colors.white),
        side: const BorderSide(color: AppColors.borda),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: false,
      ),

      // ---------------- Bottom Navigation (3 abas: Explorar, Favoritos, Reservas)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.primariaClara,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final ativo = states.contains(WidgetState.selected);
          return IconThemeData(
            color: ativo ? AppColors.primaria : AppColors.textoSecundario,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final ativo = states.contains(WidgetState.selected);
          return textTheme.labelMedium?.copyWith(
            color: ativo ? AppColors.primaria : AppColors.textoSecundario,
            fontWeight: ativo ? FontWeight.w600 : FontWeight.w500,
          );
        }),
      ),

      // ---------------- Abas "Próximas" / "Concluídas"
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primaria,
        unselectedLabelColor: AppColors.textoSecundario,
        indicatorColor: AppColors.primaria,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.borda,
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall,
      ),

      // ---------------- Diversos
      dividerTheme: const DividerThemeData(
        color: AppColors.borda,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.texto,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.controleBorder,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.cardBorder,
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaria,
      ),
    );
  }

  /// Tipografia: usa a fonte padrão da plataforma (Roboto / SF Pro),
  /// apenas ajustando pesos, tamanhos e a cor Grafite.
  static TextTheme _textTheme() {
    const base = TextStyle(color: AppColors.texto, letterSpacing: 0);
    return TextTheme(
      // Títulos grandes (Splash, cabeçalho de Login)
      headlineLarge: base.copyWith(fontSize: 30, fontWeight: FontWeight.w700),
      headlineMedium: base.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
      headlineSmall: base.copyWith(fontSize: 22, fontWeight: FontWeight.w700),
      // Títulos de tela e de seção
      titleLarge: base.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      // Nome da acomodação no card
      titleMedium: base.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      // Corpo de texto
      bodyLarge: base.copyWith(fontSize: 16, height: 1.5),
      bodyMedium: base.copyWith(fontSize: 14, height: 1.45),
      bodySmall: base.copyWith(
        fontSize: 12,
        height: 1.4,
        color: AppColors.textoSecundario,
      ),
      // Botões, chips, rótulos
      labelLarge: base.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: base.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: base.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textoSecundario,
      ),
    );
  }

  static OutlineInputBorder _bordaCampo(Color cor, {double largura = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.controleBorder,
      borderSide: BorderSide(color: cor, width: largura),
    );
  }
}

/// Estilos de texto específicos do domínio que não cabem no TextTheme.
///
/// Ex.: `Text('R\$ 250', style: AppTextStyles.preco)`
abstract final class AppTextStyles {
  /// Valor da diária no card e nos detalhes.
  static const TextStyle preco = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.texto,
  );

  /// Valor total da reserva (destaque em verde = custo-benefício).
  static const TextStyle precoTotal = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.secundaria,
  );

  /// Sufixo "/noite" ao lado do preço.
  static const TextStyle sufixoPreco = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textoSecundario,
  );
}
