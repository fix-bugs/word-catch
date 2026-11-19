import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import 'data/word_bank.dart';
import 'screens/home_screen.dart';
import 'style/palette.dart';

/// 单词捕手。
///
/// 先把词库读进内存，再进入首页。词库加载失败时留在一页简短说明上，
/// 不进入没有单词的对局。
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordCatchApp());
}

class WordCatchApp extends StatelessWidget {
  const WordCatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '单词捕手',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      scrollBehavior: const _AppScrollBehavior(),
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final scale = media.textScaler.scale(1).clamp(0.9, 1.3);
        return MediaQuery(
          data: media.copyWith(textScaler: TextScaler.linear(scale)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const _BootGate(),
    );
  }
}

class _BootGate extends StatefulWidget {
  const _BootGate();

  @override
  State<_BootGate> createState() => _BootGateState();
}

class _BootGateState extends State<_BootGate> {
  late final Future<void> _ready = WordBank.ensureLoaded();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '词库没有加载出来，请重新打开游戏。',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          );
        }
        return const HomeScreen();
      },
    );
  }
}

/// 让电脑上的鼠标也能拖动首页，不只能靠滚轮。
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
