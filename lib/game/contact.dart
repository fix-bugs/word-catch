/// 这一帧卡片和篮口发生了什么。
enum ContactKind {
  /// 还没有任何卡片碰到篮口。
  none,

  /// 玩家站着的那一列有卡片碰到篮口。
  caught,

  /// 正确答案已经整张越过篮口，而且没有被接住。
  missedTarget,
}

/// 判定时只需要列号和是不是正确答案，不依赖画面组件。
class LaneCard {
  const LaneCard({required this.lane, required this.isTarget});

  final int lane;
  final bool isTarget;
}

class ContactDecision {
  const ContactDecision(this.kind, this.index);

  final ContactKind kind;

  /// [ContactKind.caught] 或 [ContactKind.missedTarget] 对应的卡片下标。
  final int? index;
}

/// 用移动前、移动后的纵坐标判断接住还是漏接。
///
/// 纵坐标向下增大，[mouth] 是篮口那一条水平线。
/// 卡片顶部还在篮口上方，同时底部已经到达篮口，就算经过篮口。
/// 同一帧里如果既接到了字、正确答案又已经越过篮口，只算接住，避免扣两次生命。
ContactDecision decideContact({
  required List<LaneCard> cards,
  required List<double> beforeY,
  required List<double> afterY,
  required int playerLane,
  required double mouth,
  required double cardHeight,
}) {
  int? caught;
  int? missed;
  for (var i = 0; i < cards.length; i++) {
    final before = beforeY[i];
    final after = afterY[i];
    final wasAbove = before <= mouth;
    final reaches = after + cardHeight >= mouth;
    if (wasAbove && reaches && cards[i].lane == playerLane && caught == null) {
      caught = i;
    }
    if (wasAbove && after > mouth && cards[i].isTarget) {
      missed = i;
    }
  }
  if (caught != null) {
    return ContactDecision(ContactKind.caught, caught);
  }
  if (missed != null) {
    return ContactDecision(ContactKind.missedTarget, missed);
  }
  return const ContactDecision(ContactKind.none, null);
}
