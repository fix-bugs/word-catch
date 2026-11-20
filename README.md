# 单词捕手

给小朋友玩的英语小游戏。屏幕上方出现一个简短的中文意思（可以带英音），三条跑道里落下英文单词。玩家把小篮子移到正确的那一列，接住对应的单词。

玩法是原创的竖屏三列接词，不是横向跑酷。项目用 Flutter 和 Flame 搭画面、菜单和结算，结构上参考了 [Flutter Casual Games Toolkit](https://github.com/flutter/games) 里「菜单 / 对局 / 结算」的分法，但没有使用它的角色、关卡、音效，也没有广告、内购或游戏中心。

## 在浏览器里玩

不用安装 Flutter，直接打开：

https://fix-bugs.github.io/word-catch/

这是网页版。手机浏览器和电脑浏览器都可以玩。代码推到 `master` 之后，GitHub Actions 会用 `flutter build web --base-href /word-catch/` 重新构建并更新这个网站。

第一次发布需要仓库管理员打开 [Pages 设置](https://github.com/fix-bugs/word-catch/settings/pages)，在 Build and deployment 里把 Source 选成 GitHub Actions。选好之后，重新运行失败的 [Deploy web](https://github.com/fix-bugs/word-catch/actions/runs/44656413688) 工作流，网站就会打开。

## 怎么玩

首页先选主题，然后可以「开始接词」，或者「开始跟读」。

### 接词

1. 看上方的中文。三条跑道里会落下英文单词，站到正确的那一列。
2. 接对得分，连续接对会累积连击。接错，或者让正确答案漏过去，会失去一颗心。
3. 一局最多 8 题，3 颗心。心用完或题目出完，进入结算。
4. 结算页可以「再来一局」，也可以「返回首页」。

操作：

- 电脑：左右方向键，或 `A` / `D`
- 手机：点某一条跑道，或在画面上左右滑动

后面几题会稍微加快，偶尔会留出一条空跑道。前面几题留的时间比较长，方便把单词读完。

### 跟读

1. 点「开始跟读」。一组最多 8 个词；主题里词少就全部读完。
2. 屏幕上有英文、中文短义和英音。点「听一听」，设备或浏览器会读出这个单词。这是系统自带的语音，不是教材录音。
3. 点「开始录音」再跟着读。说完点「停止录音」，然后可以「听我的」。想再读一次就点「再录一次」。
4. 「下一个」进入后一个词，「跳过」先放下这个词。一组结束会看到听过、录下和跳过了几个。
5. 录音只留在这台设备上，不会上传，也不给读音打分。麦克风要等你点录音才申请。如果没有语音或麦克风，页面会用中文说明，能听的时候仍然可以听。

## 怎么运行

需要当前稳定版 Flutter（本项目用 Flutter 3.50 / Dart 3.14 开发）。

```shell
flutter pub get
flutter run
```

指定设备时，例如：

```shell
flutter run -d chrome
flutter run -d windows
```

检查代码：

```shell
flutter analyze
flutter test
```

## 支持的平台

工程里带有这些平台目录，都可以编译运行：

- Android
- iOS
- Windows
- Web（`flutter run -d chrome`，或 `flutter build web`）

手机竖着拿、电脑开一个窗口，都可以玩。窗口比较宽时，对局会收在中间，避免单词被拉得太散。Web 没有锁死竖屏，方便在桌面浏览器里开窗口。

## 词库是怎么分的

源表是人教版一年级起点 · 一年级上的单词表，共 53 个词，列是「单词、英音、美音、释义」。原文件放在 `assets/data/pep-grade1-vol1.xlsx`，只作资料，不打进安装包。

游戏实际读取的是 `assets/data/words.json`。里面的中文是改写过的短义，例如「书」「尺子」「一个（辅音前）」，不是表格里的长词典释义。英音、美音都留着，对局里只显示英音。

主题按意思归类，没有编教材单元号：

| 主题 | 词 |
| --- | --- |
| 文具 | book, ruler, pencil, schoolbag |
| 五官 | face, ear, eye, nose, mouth |
| 动物 | dog, bird, tiger, monkey, cat |
| 数字 | one 到 ten |
| 颜色 | black, yellow, blue, red, green, colour |
| 水果 | apple, pear, banana, orange |
| 其他 | 老师、我、你、是、有、喜欢等不便放进上面几类的词 |
| 混合 | 上面全部 53 个词 |

`orange` 放在水果里，意思是「橙子」。`teacher` 放在「其他」，因为它是人，不是文具。

## 声音和字体

声音是程序生成的几声短音，在 `assets/sfx/`。没有教材录音，也没有现成词库的音频。首页和对局里都可以关掉声音。

中文界面用站酷快乐体，英文和音标用 Noto Sans。两套字体都是 SIL Open Font License 1.1，说明在 `assets/fonts/NOTICE.txt` 和 `assets/fonts/OFL.txt`。
