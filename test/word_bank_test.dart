import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:word_catch/data/word_bank.dart';
import 'package:word_catch/game/contact.dart';
import 'package:word_catch/game/game_rules.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await WordBank.ensureLoaded();
  });

  test('词库正好 53 个词，并按意思分到主题里', () {
    expect(WordBank.words, hasLength(53));
    expect(WordBank.words.map((word) => word.en).toSet(), hasLength(53));

    final counts = <String, int>{};
    for (final word in WordBank.words) {
      expect(word.meaning.trim(), isNotEmpty);
      expect(word.meaning.length, lessThanOrEqualTo(12));
      expect(word.ipaUk.trim(), isNotEmpty);
      expect(word.ipaUs.trim(), isNotEmpty);
      counts[word.themeId] = (counts[word.themeId] ?? 0) + 1;
    }

    expect(counts, {
      'stationery': 4,
      'face': 5,
      'animal': 5,
      'number': 10,
      'color': 6,
      'fruit': 4,
      'other': 19,
    });

    final stationery = WordBank.wordsFor('stationery').map((word) => word.en);
    expect(stationery, ['book', 'ruler', 'pencil', 'schoolbag']);
    expect(WordBank.wordsFor('fruit').map((word) => word.en), [
      'apple',
      'pear',
      'banana',
      'orange',
    ]);
    expect(
      WordBank.wordsFor('other').map((word) => word.en),
      contains('teacher'),
    );
    expect(WordBank.wordsFor(WordBank.mixedId), hasLength(53));
  });

  test('出题一定包含正确答案，并且不和上一题重复', () {
    final pool = WordBank.wordsFor('animal');
    for (var seed = 0; seed < 40; seed++) {
      final wave = WordBank.planWave(
        pool: pool,
        random: Random(seed),
        avoidId: 'dog',
        allowGap: false,
      );
      expect(wave.target.id, isNot('dog'));
      expect(
        wave.slots.where((slot) => slot?.id == wave.target.id),
        hasLength(1),
      );
      expect(wave.slots.whereType<Object>(), hasLength(3));
      final ids = wave.slots
          .map((slot) => slot?.id)
          .whereType<String>()
          .toList();
      expect(ids.toSet(), hasLength(ids.length));
      expect(wave.ranks.toSet(), {0, 1, 2});
    }
  });

  test('允许空跑道时，正确答案仍然在场上', () {
    final pool = WordBank.wordsFor('number');
    var sawGap = false;
    for (var seed = 0; seed < 80; seed++) {
      final wave = WordBank.planWave(
        pool: pool,
        random: Random(seed),
        avoidId: null,
        allowGap: true,
      );
      expect(
        wave.slots.where((slot) => slot?.id == wave.target.id),
        hasLength(1),
      );
      final filled = wave.slots.whereType<Object>().length;
      expect(filled, anyOf(2, 3));
      if (filled == 2) {
        sawGap = true;
      }
    }
    expect(sawGap, isTrue);
  });

  test('下落时间越往后越短，但有下限', () {
    expect(GameRules.fallSeconds(1), greaterThan(GameRules.fallSeconds(4)));
    expect(GameRules.fallSeconds(4), greaterThan(GameRules.fallSeconds(8)));
    expect(GameRules.fallSeconds(30), 2.0);
    expect(GameRules.pointsForCombo(1), 10);
    expect(GameRules.pointsForCombo(3), 20);
  });

  test('站在正确列上会接住，站错列会漏掉', () {
    const cards = [
      LaneCard(lane: 0, isTarget: false),
      LaneCard(lane: 1, isTarget: true),
      LaneCard(lane: 2, isTarget: false),
    ];

    final caught = decideContact(
      cards: cards,
      beforeY: const [70, 70, 70],
      afterY: const [85, 85, 85],
      playerLane: 1,
      mouth: 100,
      cardHeight: 20,
    );
    expect(caught.kind, ContactKind.caught);
    expect(caught.index, 1);

    // 玩家还站在没落到篮口的那一列，正确答案已经越过篮口。
    final missed = decideContact(
      cards: cards,
      beforeY: const [40, 95, 40],
      afterY: const [55, 115, 55],
      playerLane: 0,
      mouth: 100,
      cardHeight: 20,
    );
    expect(missed.kind, ContactKind.missedTarget);
    expect(missed.index, 1);

    // 干扰项先碰到篮口，算接错，不再同时记一次漏接。
    final wrong = decideContact(
      cards: cards,
      beforeY: const [85, 40, 40],
      afterY: const [95, 50, 50],
      playerLane: 0,
      mouth: 100,
      cardHeight: 20,
    );
    expect(wrong.kind, ContactKind.caught);
    expect(wrong.index, 0);
  });

  test('同一帧里接住优先于漏接，避免扣两次', () {
    const cards = [LaneCard(lane: 1, isTarget: true)];
    final decision = decideContact(
      cards: cards,
      beforeY: const [90],
      afterY: const [130],
      playerLane: 1,
      mouth: 100,
      cardHeight: 20,
    );
    expect(decision.kind, ContactKind.caught);
  });
}
