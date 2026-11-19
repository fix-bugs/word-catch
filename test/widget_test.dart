import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:word_catch/audio/sound_board.dart';
import 'package:word_catch/data/word_bank.dart';
import 'package:word_catch/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SoundBoard.enabled = false;
    await WordBank.ensureLoaded();
  });

  testWidgets('窄屏和宽窗口的首页都能排开', (tester) async {
    Future<void> pumpAt(Size size) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(const WordCatchApp());
      await tester.pumpAndSettle();
      expect(find.text('单词捕手'), findsOneWidget);
      expect(find.text('开始游戏'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await pumpAt(const Size(360, 640));
    await pumpAt(const Size(1280, 800));
  });

  testWidgets('可以从首页选题，玩完一局，再看到结算', (tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const WordCatchApp());
    await tester.pumpAndSettle();

    expect(find.text('单词捕手'), findsOneWidget);
    expect(find.text('开始游戏'), findsOneWidget);
    expect(find.text('怎么玩'), findsOneWidget);
    expect(find.text('动物'), findsOneWidget);
    expect(find.text('混合'), findsOneWidget);
    expect(find.text('其他'), findsOneWidget);

    await tester.ensureVisible(find.text('水果'));
    await tester.tap(find.text('水果'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('开始游戏'));
    await tester.tap(find.text('开始游戏'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('返回'), findsNothing);
    expect(find.byTooltip('返回'), findsOneWidget);

    for (var i = 0; i < 40 && find.text('本局结束').evaluate().isEmpty; i++) {
      await tester.pump(const Duration(seconds: 2));
    }

    expect(find.text('本局结束'), findsOneWidget);
    expect(find.text('得分'), findsOneWidget);
    expect(find.text('最高连击'), findsOneWidget);
    expect(find.text('接住单词'), findsOneWidget);
    expect(find.text('再来一局'), findsOneWidget);
    expect(find.text('返回首页'), findsOneWidget);

    await tester.tap(find.text('返回首页'));
    await tester.pumpAndSettle();
    expect(find.text('开始游戏'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
