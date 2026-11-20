import 'dart:async';
import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart';

import '../audio/sound_board.dart';
import '../data/word_bank.dart';
import '../data/word_entry.dart';
import 'components/catcher_basket.dart';
import 'components/lane_backdrop.dart';
import 'components/playfield_background.dart';
import 'components/word_card.dart';
import 'contact.dart';
import 'game_rules.dart';
import 'hud_model.dart';
import 'session_result.dart';

enum _WavePhase { idle, falling }

/// 三列接单词。
///
/// 和横向跑酷不一样：这里没有前进和跳跃。中文提示停在屏幕上方，
/// 英文胶囊从三条跑道落下来，玩家只要站到正确的那一列。
class WordCatchGame extends FlameGame {
  WordCatchGame({required this.themeId, math.Random? random})
    : _random = random ?? math.Random();

  bool _cameraReady = false;

  final String themeId;
  final math.Random _random;
  final HudModel hud = HudModel();

  int lives = GameRules.lives;
  int score = 0;
  int combo = 0;
  int bestCombo = 0;
  int caught = 0;
  int round = 0;

  /// 玩家当前站的列，0 是最左边。开局站在中间。
  int lane = 1;

  double laneWidth = 0;
  double cardWidth = 0;
  double cardHeight = 0;
  double fallSpeed = 120;

  PlayfieldBackground? _background;
  LaneBackdrop? _lanes;
  CatcherBasket? _catcher;

  _WavePhase _phase = _WavePhase.idle;
  double _wait = 0.45;
  double? _finishIn;
  bool _finished = false;
  String? _lastTargetId;
  WordEntry? _target;

  static const List<String> _cheers = ['接对了！', '接对了！', '太棒啦！', '真聪明！'];

  @override
  Color backgroundColor() => const Color(0xFFBEE7F8);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _background = PlayfieldBackground();
    _lanes = LaneBackdrop();
    _catcher = CatcherBasket();
    await world.addAll([_background!, _lanes!, _catcher!]);
    _layout();
    hud
      ..prompt = '准备接住'
      ..phonetic = ''
      ..feedback = '看中文，接住英文单词'
      ..hint = '点跑道，或按左右方向键'
      ..tone = FeedbackTone.neutral
      ..round = 0
      ..totalRounds = GameRules.rounds;
    _publish();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // 等画面有了尺寸再改相机，构造函数里读 size 会直接报错。
    // 原点放在左上角，后面的组件坐标就和像素对齐。
    if (!_cameraReady && size.x > 0 && size.y > 0) {
      camera.viewfinder.anchor = Anchor.topLeft;
      camera.viewfinder.position = Vector2.zero();
      _cameraReady = true;
    }
    _layout();
  }

  /// 点某一列，或键盘直接选列。
  void moveTo(int next) {
    final clamped = next < 0 ? 0 : (next > 2 ? 2 : next);
    if (clamped == lane) {
      return;
    }
    lane = clamped;
    final catcher = _catcher;
    if (catcher != null && laneWidth > 0) {
      catcher.targetX = _laneCenter(lane);
    }
    _lanes?.activeLane = lane;
    unawaited(SoundBoard.instance.play('move'));
  }

  void moveBy(int delta) {
    moveTo(lane + delta);
  }

  /// 手指点在画面上的横坐标。
  void moveToPoint(double x) {
    if (laneWidth <= 0) {
      return;
    }
    moveTo((x / laneWidth).floor());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_finished) {
      return;
    }
    if (_finishIn != null) {
      _finishIn = _finishIn! - dt;
      if (_finishIn! <= 0) {
        _finishIn = null;
        _finish();
      }
      return;
    }
    if (_phase == _WavePhase.idle) {
      _wait -= dt;
      if (_wait <= 0) {
        _spawnWave();
      }
      return;
    }
    _tickCards(dt);
  }

  void _layout() {
    if (!hasLayout) {
      return;
    }
    final view = size;
    if (view.x < 10 || view.y < 10) {
      return;
    }
    laneWidth = view.x / 3;
    cardWidth = math.min(laneWidth * 0.86, 200.0);
    cardHeight = math.min(84.0, math.max(60.0, view.y * 0.12));
    _background?.size = view.clone();
    _lanes?.size = view.clone();
    _lanes?.activeLane = lane;

    final catcher = _catcher;
    if (catcher != null) {
      final catcherHeight = math.min(132.0, view.y * 0.24);
      final catcherWidth = math.min(laneWidth * 0.82, 170.0);
      catcher.size = Vector2(catcherWidth, catcherHeight);
      catcher.position = Vector2(_laneCenter(lane), view.y - 8);
      catcher.targetX = catcher.position.x;
    }

    for (final card in world.children.whereType<WordCard>()) {
      card.size = Vector2(cardWidth, cardHeight);
      card.position.x = _laneCenter(card.lane) - cardWidth / 2;
    }
  }

  double _laneCenter(int index) => laneWidth * (index + 0.5);

  void _spawnWave() {
    final catcher = _catcher;
    if (catcher == null || size.x < 10 || size.y < 10 || cardHeight < 1) {
      _wait = 0.05;
      return;
    }
    final pool = WordBank.wordsFor(themeId);
    final plan = WordBank.planWave(
      pool: pool,
      random: _random,
      avoidId: _lastTargetId,
      allowGap: round >= 3,
    );
    round += 1;
    _lastTargetId = plan.target.id;
    _target = plan.target;
    _phase = _WavePhase.falling;

    final mouth = catcher.mouthY;
    final stagger = _stagger(mouth);
    final leadY = _yForRank(2, stagger, mouth);
    final distance = (mouth - cardHeight) - leadY;
    fallSpeed = math.max(90.0, distance) / GameRules.fallSeconds(round);

    for (var index = 0; index < 3; index++) {
      final word = plan.slots[index];
      if (word == null) {
        continue;
      }
      final card = WordCard(
        word: word,
        lane: index,
        isTarget: word.id == plan.target.id,
        color: WordBank.themeById(word.themeId).color,
      );
      card.size = Vector2(cardWidth, cardHeight);
      card.position = Vector2(
        _laneCenter(index) - cardWidth / 2,
        _yForRank(plan.ranks[index], stagger, mouth),
      );
      world.add(card);
    }

    hud
      ..prompt = plan.target.meaning
      ..phonetic = '英 /${plan.target.ipaUk}/'
      ..feedback = round == 1 ? '站到正确单词的那一列' : ''
      ..hint = round == 1 ? '点跑道，或按左右方向键' : ''
      ..tone = FeedbackTone.neutral
      ..round = round;
    _publish();
  }

  double _stagger(double mouth) {
    final room = mouth - cardHeight - 130;
    final stagger = math.min(68.0, room / 2);
    if (stagger < 22) {
      return 22;
    }
    return stagger;
  }

  /// rank 0 在最上面，最晚到达；rank 2 最靠下，最早到达。
  double _yForRank(int rank, double stagger, double mouth) {
    var y = 16.0 + rank * stagger;
    final limit = mouth - cardHeight - 80;
    if (y > limit) {
      y = limit - (2 - rank) * 18;
    }
    return y;
  }

  void _tickCards(double dt) {
    final catcher = _catcher;
    if (catcher == null) {
      return;
    }
    final cards = world.children.whereType<WordCard>().toList();
    if (cards.isEmpty) {
      _resolveMiss();
      return;
    }
    final mouth = catcher.mouthY;
    final before = [for (final card in cards) card.position.y];
    for (final card in cards) {
      card.position.y += fallSpeed * dt;
    }
    final decision = decideContact(
      cards: [
        for (final card in cards)
          LaneCard(lane: card.lane, isTarget: card.isTarget),
      ],
      beforeY: before,
      afterY: [for (final card in cards) card.position.y],
      playerLane: lane,
      mouth: mouth,
      cardHeight: cardHeight,
    );
    if (decision.kind == ContactKind.caught) {
      _resolveCatch(cards[decision.index!]);
      return;
    }
    if (decision.kind == ContactKind.missedTarget) {
      _resolveMiss();
      return;
    }
    for (final card in cards) {
      if (!card.isTarget && card.position.y > mouth) {
        card.removeFromParent();
      }
    }
  }

  void _resolveCatch(WordCard card) {
    if (card.isTarget) {
      combo += 1;
      if (combo > bestCombo) {
        bestCombo = combo;
      }
      final gain = GameRules.pointsForCombo(combo);
      score += gain;
      caught += 1;
      final cheer = _cheers[_random.nextInt(_cheers.length)];
      hud
        ..feedback = '$cheer ${card.word.en}  +$gain'
        ..tone = FeedbackTone.good;
      unawaited(SoundBoard.instance.play('correct'));
    } else {
      combo = 0;
      lives = math.max(0, lives - 1);
      hud
        ..feedback = '再试试～ 要找的是 ${_target?.en ?? ''}'
        ..tone = FeedbackTone.bad;
      unawaited(SoundBoard.instance.play('wrong'));
    }
    _endWave();
  }

  void _resolveMiss() {
    combo = 0;
    lives = math.max(0, lives - 1);
    hud
      ..feedback = '漏掉啦～ ${_target?.en ?? ''}'
      ..tone = FeedbackTone.bad;
    unawaited(SoundBoard.instance.play('miss'));
    _endWave();
  }

  void _endWave() {
    _clearCards();
    _phase = _WavePhase.idle;
    hud.hint = '';
    _publish();
    if (lives <= 0 || round >= GameRules.rounds) {
      _finishIn = 0.95;
    } else {
      _wait = 0.9;
    }
  }

  void _clearCards() {
    for (final card in world.children.whereType<WordCard>().toList()) {
      card.removeFromParent();
    }
  }

  void _finish() {
    if (_finished) {
      return;
    }
    _finished = true;
    final theme = WordBank.themeById(themeId);
    hud
      ..finished = true
      ..result = SessionResult(
        themeId: themeId,
        themeName: theme.name,
        themeColor: theme.color,
        score: score,
        bestCombo: bestCombo,
        caught: caught,
        roundsPlayed: round,
      );
    _publish();
    pauseEngine();
  }

  void _publish() {
    hud
      ..lives = lives
      ..score = score
      ..combo = combo
      ..bestCombo = bestCombo
      ..totalRounds = GameRules.rounds;
    _catcher?.combo = combo;
    _lanes?.activeLane = lane;
    hud.touch();
  }
}
