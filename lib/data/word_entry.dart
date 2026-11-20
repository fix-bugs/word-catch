/// 词库里的一个英文单词。
///
/// [meaning] 是给儿童看的短义，不是原始表格里的长词典释义。
class WordEntry {
  const WordEntry({
    required this.id,
    required this.en,
    required this.ipaUk,
    required this.ipaUs,
    required this.meaning,
    required this.themeId,
  });

  final String id;
  final String en;

  /// 英音，游戏里默认显示这一条。
  final String ipaUk;

  /// 美音，保留在数据里，方便以后切换，当前对局里不展示。
  final String ipaUs;

  final String meaning;
  final String themeId;
}
