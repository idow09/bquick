import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:bquick/score_repository.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class BQuickBloc {
  static const int WIDTH = 6;
  static const int TILES_COUNT = WIDTH * WIDTH;

  final Random _random = Random();
  final Map<int, int> _num2index = <int, int>{};
  final DateFormat _timeFormatter = DateFormat('mm:ss.SSS');
  final StreamController<int> _clicksController = StreamController<int>();
  final StreamController<void> _restartsController = StreamController<void>();

  Stopwatch _stopwatch;
  Function _periodicRunner;
  ScoreRepository _scoreRepository;

  List<BQuickTile> _curState;
  int _curNum;
  Duration _highScore;
  Timer _updateStopwatchTimer;

  BehaviorSubject<UnmodifiableListView<BQuickTile>> _gameStateSubject;
  BehaviorSubject<int> _curNumSubject;
  BehaviorSubject<Duration> _curStopwatchSubject;
  BehaviorSubject<GameStatus> _gameStatusSubject;
  BehaviorSubject<Duration> _highScoreSubject;

  BQuickBloc(
      {Stopwatch stopwatch,
      Function periodicRunner,
      ScoreRepository scoreRepository}) {
    if (stopwatch == null) {
      _stopwatch = Stopwatch();
    } else {
      _stopwatch = stopwatch;
    }
    if (periodicRunner == null) {
      _periodicRunner = (Duration d, Function c) => Timer.periodic(d, c);
    } else {
      _periodicRunner = periodicRunner;
    }
    if (scoreRepository == null) {
      _scoreRepository = ScoreRepository();
    } else {
      _scoreRepository = scoreRepository;
    }
    resetState();

    _gameStateSubject = BehaviorSubject<UnmodifiableListView<BQuickTile>>(
        seedValue: UnmodifiableListView<BQuickTile>(_curState));
    _curNumSubject = BehaviorSubject<int>(seedValue: _curNum);
    _curStopwatchSubject =
        BehaviorSubject<Duration>(seedValue: Duration(seconds: 0));
    _gameStatusSubject =
        BehaviorSubject<GameStatus>(seedValue: GameStatus.running);
    _highScoreSubject = BehaviorSubject<Duration>();

    _scoreRepository.fetchHighScore().then((int highScore) {
      final Duration dur = Duration(milliseconds: highScore);
      _highScore = dur;
      _highScoreSubject.add(dur);
    }).catchError((Object _) {});

    _clicksController.stream.listen((int numClicked) async {
      handleClickEvent(numClicked);
    });
    _restartsController.stream.listen((_) async {
      restartGame();
    });
  }

  void resetState() {
    _curState = List.generate(TILES_COUNT, (int i) => BQuickTile(i + 1, true));
    _curState.shuffle(_random);
    _curNum = 1;

    _curState.asMap().forEach((int i, BQuickTile tile) {
      _num2index[tile.value] = i;
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

  Stream<UnmodifiableListView<BQuickTile>> get gameState =>
      _gameStateSubject.stream;

  Stream<int> get curNum => _curNumSubject.stream;

  Stream<String> get curStopwatch => _curStopwatchSubject.stream
      .map((Duration duration) => duration.inMilliseconds)
      .map((int ms) => DateTime.fromMillisecondsSinceEpoch(ms))
      .map(_timeFormatter.format)
      .map((String str) => str.substring(0, str.length - 1));

  Stream<GameStatus> get gameStatus => _gameStatusSubject.stream;

  Stream<String> get highScore => _highScoreSubject.stream
      .map((Duration duration) => duration.inMilliseconds)
      .map((int ms) => DateTime.fromMillisecondsSinceEpoch(ms))
      .map(_timeFormatter.format)
      .map((String str) => str.substring(0, str.length - 1))
      .startWith('- - : - - . - -');

  void dispose() {
    _clicksController.close();
    _restartsController.close();
    _gameStateSubject.close();
    _curNumSubject.close();
    _curStopwatchSubject.close();
    _gameStatusSubject.close();
    _highScoreSubject.close();
  }

  void handleClickEvent(int numClicked) {
    print('User clicked on $numClicked.');
    if (numClicked == _curNum) {
      handleCorrectNumClicked(numClicked);
    }
  }

  void handleCorrectNumClicked(int numClicked) {
    if (numClicked == 1) {
      startStopwatchStream();
    }
    if (numClicked == TILES_COUNT) {
      endGame();
    }
    updateState(numClicked);
    publishState();
  }

  void updateState(int numClicked) {
    _curState[_num2index[numClicked]].visible = false;
    _curNum++;
  }

  void publishState() {
    _gameStateSubject.add(UnmodifiableListView<BQuickTile>(_curState));
    _curNumSubject.add(_curNum);
  }

  void restartGame() {
    print('Restarting game.');
    resetState();
    publishState();
    _curStopwatchSubject.add(_stopwatch.elapsed);
    _gameStatusSubject.add(GameStatus.running);
  }

  void startStopwatchStream() {
    _stopwatch.start();
    _updateStopwatchTimer =
        _periodicRunner(Duration(milliseconds: 30), (Timer _) async {
      _curStopwatchSubject.add(_stopwatch.elapsed);
    });
  }

  void endGame() {
    _stopwatch.stop();
    final int ms = _stopwatch.elapsedMilliseconds;
    print('Game ended. Total time: $ms milliseconds.');
    if (_highScore == null || _stopwatch.elapsed < _highScore) {
      _highScore = _stopwatch.elapsed;
      _highScoreSubject.add(_highScore);
      _scoreRepository.storeHighScore(_highScore.inMilliseconds);
    }
    _gameStatusSubject.add(GameStatus.finished);
  }
}

class BQuickTile {
  final int value;
  bool visible;

  BQuickTile(this.value, this.visible);
}

enum GameStatus { running, finished }
