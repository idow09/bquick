import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:chik_chak/score_repository.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  static const WIDTH = 6;
  static const TILES_COUNT = WIDTH * WIDTH;

  final Random _random = Random();
  final Map<int, int> _num2index = Map();
  final DateFormat _timeFormatter = new DateFormat('mm:ss.SSS');
  final StreamController<int> _clicksController = StreamController<int>();
  final StreamController<void> _restartsController = StreamController<void>();

  Stopwatch _stopwatch;
  Function _periodicRunner;
  ScoreRepository _scoreRepository;

  List<ChikChakTile> _curState;
  int _curNum;
  Duration _highScore;
  Timer _updateStopwatchTimer;

  BehaviorSubject<UnmodifiableListView<ChikChakTile>> _gameStateSubject;
  BehaviorSubject<int> _curNumSubject;
  BehaviorSubject<Duration> _curStopwatchSubject;
  BehaviorSubject<GameStatus> _gameStatusSubject;
  BehaviorSubject<Duration> _highScoreSubject;

  ChikChakBloc(
      {Stopwatch stopwatch,
      Function periodicRunner,
      ScoreRepository scoreRepository}) {
    if (stopwatch == null) {
      _stopwatch = Stopwatch();
    } else {
      _stopwatch = stopwatch;
    }
    if (periodicRunner == null) {
      _periodicRunner = (d, c) => Timer.periodic(d, c);
    } else {
      _periodicRunner = periodicRunner;
    }
    if (scoreRepository == null) {
      _scoreRepository = ScoreRepository();
    } else {
      _scoreRepository = scoreRepository;
    }
    resetState();

    _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
        seedValue: UnmodifiableListView(_curState));
    _curNumSubject = BehaviorSubject<int>(seedValue: _curNum);
    _curStopwatchSubject =
        BehaviorSubject<Duration>(seedValue: Duration(seconds: 0));
    _gameStatusSubject =
        BehaviorSubject<GameStatus>(seedValue: GameStatus.running);
    _highScoreSubject = BehaviorSubject<Duration>();

    _scoreRepository
        .fetchHighScore()
        .then((highScore) =>
            _highScoreSubject.add(Duration(milliseconds: highScore)))
        .catchError((_) {});

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
      .map(_timeFormatter.format);

  Stream<GameStatus> get gameStatus => _gameStatusSubject.stream;

  Stream<String> get highScore => _highScoreSubject.stream
      .map((duration) => duration.inMilliseconds)
      .map((ms) => DateTime.fromMillisecondsSinceEpoch(ms))
      .map(_timeFormatter.format)
      .startWith("- - : - - . - - -");

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
    if (numClicked == 1) startStopwatchStream();
    if (numClicked == TILES_COUNT) endGame();
    updateState(numClicked);
    publishState();
  }

  void updateState(int numClicked) {
    _curState[_num2index[numClicked]].visible = false;
    _curNum++;
  }

  void publishState() {
    _gameStateSubject.add(UnmodifiableListView(_curState));
    _curNumSubject.add(_curNum);
  }

  void restartGame() {
    print("Restarting game.");
    resetState();
    publishState();
    _curStopwatchSubject.add(_stopwatch.elapsed);
    _gameStatusSubject.add(GameStatus.running);
  }

  void startStopwatchStream() async {
    _stopwatch.start();
    _updateStopwatchTimer =
        _periodicRunner(Duration(milliseconds: 30), (_) async {
      _curStopwatchSubject.add(_stopwatch.elapsed);
    });
  }

  void endGame() {
    _stopwatch.stop();
    final ms = _stopwatch.elapsedMilliseconds;
    print("Game ended. Total time: $ms milliseconds.");
    if (_highScore == null || _stopwatch.elapsed < _highScore) {
      _highScore = _stopwatch.elapsed;
      _highScoreSubject.add(_highScore);
      _scoreRepository.storeHighScore(_highScore.inMilliseconds);
    }
    _gameStatusSubject.add(GameStatus.finished);
  }
}

class ChikChakTile {
  final int num;
  var visible;

  ChikChakTile(this.num, this.visible);
}

enum GameStatus { running, finished }
