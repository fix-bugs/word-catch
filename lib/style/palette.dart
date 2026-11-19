import 'package:material_ui/material_ui.dart';

/// 界面用的字体。中文走快乐体，英文和音标走 Noto Sans。
class AppFonts {
  const AppFonts._();

  static const String display = 'ZCOOLKuaiLe';
  static const String latin = 'NotoSans';
}

/// 整款游戏共用的颜色。
class Palette {
  const Palette._();

  static const Color cream = Color(0xFFFFF6EE);
  static const Color sky = Color(0xFF8FD3F4);
  static const Color coral = Color(0xFFFF7A59);
  static const Color ink = Color(0xFF243049);
  static const Color good = Color(0xFF1B8A4A);
  static const Color bad = Color(0xFFD3543C);
}

ThemeData buildAppTheme() {
  return ThemeData(
    fontFamily: AppFonts.display,
    fontFamilyFallback: const [AppFonts.latin],
    colorScheme: ColorScheme.fromSeed(seedColor: Palette.coral),
    scaffoldBackgroundColor: Palette.cream,
  );
}
