import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  static const TILES_COUNT = 9;
  static const WIDTH = 3;

  final Random _random = Random();

  final Stopwatch _stopwatch = Stopwatch();

  final Map<int, int> _num2index = Map();

  final DateFormat _dateFormatter = new DateFormat('mm:ss.SSS');

  List<ChikChakTile> _curState;

  int _curNum;

  Timer _updateStopwatchTimer;

  BehaviorSubject<UnmodifiableListView<ChikChakTile>> _gameStateSubject;

  BehaviorSubject<int> _curNumSubject;

  BehaviorSubject<Duration> _curStopwatchSubject;

  final StreamController<int> _clicksController = StreamController<int>();

  final StreamController<void> _restartsController = StreamController<void>();

  ChikChakBloc() {
    resetState();

    _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
        seedValue: UnmodifiableListView(_curState));

    _curNumSubject = BehaviorSubject<int>(seedValue: _curNum);

    _curStopwatchSubject =
        BehaviorSubject<Duration>(seedValue: Duration(seconds: 0));

    _clicksController.stream.listen((numClicked) async {
      handleClickEvent(numClicked);
    });

    _restartsController.stream.listen((_) async {
      restartGame();
    });
  }

  void resetState() {
    _curState = List.generate(TILES_COUNT, (i) => ChikChakTile(i + 1, true));
    _curState.shuffle(_random);
    _curNum = 1;

    _curState.asMap().forEach((i, tile) {
      _num2index[tile.num] = i;
    });

    resetStopwatch();
  }

  void resetStopwatch() {
    _updateStopwatchTimer?.cancel();
    _stopwatch.stop();
    _stopwatch.reset();
  }

  Sink<int> get clicks => _clicksController.sink;

  Sink<void> get restarts => _restartsController.sink;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  Stream<int> get curNum => _curNumSubject.stream;

  Stream<String> get curStopwatch => _curStopwatchSubject.stream
      .map((duration) => duration.inMilliseconds)
      .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
      .map(_dateFormatter.format);

  void dispose() {
    _clicksController.close();
    _restartsController.close();
    _gameStateSubject.close();
    _curNumSubject.close();
    _curStopwatchSubject.close();
  }

  void handleClickEvent(int numClicked) {
    print('User clicked on $numClicked.');
    if (numClicked == _curNum) {
      if (numClicked == 1) startStopwatchStream();
      if (numClicked == TILES_COUNT) winGame();
      updateState(numClicked);
      publishState();
    }
  }

  void updateState(int numClicked) {
    _curState[_num2index[numClicked]].visible = false;
    _curNum++;
  }

  void publishState() {
    _gameStateSubject.add(UnmodifiableListView(_curState));
    _curNumSubject.add(_curNum);
    _curStopwatchSubject.add(_stopwatch.elapsed);
  }

  void restartGame() {
    print("Restarting game.");
    resetState();
    publishState();
  }

  void startStopwatchStream() async {
    _stopwatch.start();
    _updateStopwatchTimer =
        Timer.periodic(Duration(milliseconds: 30), (_) async {
      _curStopwatchSubject.add(_stopwatch.elapsed);
    });
  }

  void winGame() {
    _stopwatch.stop();
    final ms = _stopwatch.elapsedMilliseconds;
    print("You did it! In only $ms milliseconds!");
//    publishWin(time)
  }
}

class ChikChakTile {
  final int num;
  var visible;

  ChikChakTile(this.num, this.visible);
}
