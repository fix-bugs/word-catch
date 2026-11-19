import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'word_entry.dart';

/// 首页上的一个主题。
///
/// 「混合」不是表格里的分类，而是把全部单词放在一起的玩法。
class WordTheme {
  const WordTheme({
    required this.id,
    required this.name,
    required this.blurb,
    required this.color,
  });

  final String id;
  final String name;
  final String blurb;
  final Color color;
}

/// 一题的出题结果：正确单词放在哪一列，干扰项放在哪一列。
class WavePlan {
  const WavePlan({
    required this.target,
    required this.slots,
    required this.ranks,
  });

  final WordEntry target;

  /// 长度固定为 3。空位表示这一列这次没有单词，玩家站在空列会漏接。
  final List<WordEntry?> slots;

  /// 和三列一一对应。数字越大，卡片起始位置越靠下，越早到达篮口。
  final List<int> ranks;
}

/// 读取 [assets/data/words.json]，并负责按主题抽题。
class WordBank {
  WordBank._();

  static const mixedId = 'mixed';

  static const WordTheme mixed = WordTheme(
    id: mixedId,
    name: '混合',
    blurb: '把全部单词混在一起',
    color: Color(0xFFFF8A5B),
  );

  static List<WordTheme>? _themes;
  static List<WordEntry>? _words;

  static bool get isLoaded => _words != null;

  static Future<void> ensureLoaded() async {
    if (_words != null) {
      return;
    }
    final raw = await rootBundle.loadString('assets/data/words.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final themes = <WordTheme>[];
    for (final item in decoded['themes'] as List<dynamic>) {
      final map = item as Map<String, dynamic>;
      themes.add(
        WordTheme(
          id: map['id']! as String,
          name: map['name']! as String,
          blurb: map['blurb']! as String,
          color: _colorFromHex(map['color']! as String),
        ),
      );
    }
    final words = <WordEntry>[];
    for (final item in decoded['words'] as List<dynamic>) {
      final map = item as Map<String, dynamic>;
      words.add(
        WordEntry(
          id: map['id']! as String,
          en: map['en']! as String,
          ipaUk: map['ipaUk']! as String,
          ipaUs: map['ipaUs']! as String,
          meaning: map['meaning']! as String,
          themeId: map['theme']! as String,
        ),
      );
    }
    _themes = themes;
    _words = words;
  }

  static List<WordTheme> get themes {
    final loaded = _themes;
    if (loaded == null) {
      throw StateError('词库还没加载');
    }
    return List<WordTheme>.unmodifiable([...loaded, mixed]);
  }

  static List<WordEntry> get words {
    final loaded = _words;
    if (loaded == null) {
      throw StateError('词库还没加载');
    }
    return List<WordEntry>.unmodifiable(loaded);
  }

  static WordTheme themeById(String id) {
    for (final theme in themes) {
      if (theme.id == id) {
        return theme;
      }
    }
    return mixed;
  }

  /// 某个主题下的单词。混合模式返回全部，并保持词表原来的顺序。
  static List<WordEntry> wordsFor(String themeId) {
    if (themeId == mixedId) {
      return words;
    }
    return words
        .where((word) => word.themeId == themeId)
        .toList(growable: false);
  }

  /// 生成一题。
  ///
  /// 正确答案尽量不和上一题相同。干扰项优先来自同一词库。
  /// [allowGap] 为真时，有时会留出一条空跑道，这样站错地方就会漏接。
  static WavePlan planWave({
    required List<WordEntry> pool,
    required Random random,
    String? avoidId,
    required bool allowGap,
  }) {
    if (pool.length < 2) {
      throw StateError('这个主题的单词太少，没法出题');
    }
    final fresh = pool.where((word) => word.id != avoidId).toList();
    final choices = fresh.isEmpty ? pool : fresh;
    final target = choices[random.nextInt(choices.length)];
    final others = pool.where((word) => word.id != target.id).toList()
      ..shuffle(random);
    final wantDistractors = allowGap && random.nextDouble() < 0.34 ? 1 : 2;
    final distractors = others
        .take(min(wantDistractors, others.length))
        .toList();

    final slots = List<WordEntry?>.filled(3, null);
    final laneOrder = <int>[0, 1, 2]..shuffle(random);
    slots[laneOrder.first] = target;
    for (var i = 0; i < distractors.length; i++) {
      slots[laneOrder[i + 1]] = distractors[i];
    }
    final ranks = <int>[0, 1, 2]..shuffle(random);
    return WavePlan(target: target, slots: slots, ranks: ranks);
  }

  static Color _colorFromHex(String hex) {
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse(cleaned, radix: 16) + 0xFF000000);
  }
}
