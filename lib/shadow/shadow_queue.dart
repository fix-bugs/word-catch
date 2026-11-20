import 'dart:math';

import '../data/word_entry.dart';

/// 一组跟读最多几个词。主题词少就全部读完，多了就抽一小段。
const int shadowSessionLimit = 8;

/// 从主题词库里抽出这一组要跟读的词，顺序打乱，不重复。
List<WordEntry> buildShadowQueue(List<WordEntry> pool, Random random) {
  final copy = [...pool]..shuffle(random);
  if (copy.length <= shadowSessionLimit) {
    return copy;
  }
  return copy.sublist(0, shadowSessionLimit);
}
