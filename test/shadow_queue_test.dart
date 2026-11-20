import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_catch/data/word_bank.dart';
import 'package:word_catch/shadow/shadow_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WordBank.ensureLoaded();
  });

  test('词少的主题会全部跟读，词多的主题只抽 8 个', () {
    final animals = buildShadowQueue(WordBank.wordsFor('animal'), Random(1));
    expect(animals, hasLength(5));
    expect(animals.map((word) => word.id).toSet(), hasLength(5));

    final mixed = buildShadowQueue(WordBank.wordsFor('mixed'), Random(2));
    expect(mixed, hasLength(shadowSessionLimit));
    expect(mixed.map((word) => word.id).toSet(), hasLength(shadowSessionLimit));
    final allIds = WordBank.words.map((word) => word.id).toSet();
    expect(allIds.containsAll(mixed.map((word) => word.id)), isTrue);
  });
}
