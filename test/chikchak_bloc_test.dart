import 'dart:async';
import 'dart:collection';

import 'package:chik_chak/chikchak_bloc.dart';
import 'package:chik_chak/score_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockStopwatch extends Mock implements Stopwatch {}

class MockScoreRepository extends Mock implements ScoreRepository {}

void main() {
  ChikChakBloc _bloc;
  var _timerCallback;

  final ScoreRepository _mockRepo = MockScoreRepository();
  final _fastStopwatch = MockStopwatch();

  setUp(() {
    var counter = 0;
    when(_fastStopwatch.elapsed)
        .thenAnswer((_) => Duration(seconds: counter++));

    var _fastRunner = (_, c) {
      _timerCallback = c;
      return null;
    };
    when(_mockRepo.fetchHighScore()).thenAnswer((_) => Future.value(
        Duration(minutes: 2, seconds: 51, milliseconds: 17).inMilliseconds));

    _bloc = ChikChakBloc(
        stopwatch: _fastStopwatch,
        periodicRunner: _fastRunner,
        scoreRepository: _mockRepo);
  });

  group('In initial state ', () {
    group('tiles ', () {
      UnmodifiableListView<ChikChakTile> _initialState;
      setUp(() async => _initialState = await _bloc.gameState.first);

      test('are all visible', () async {
        testAllTilesAreVisible(_initialState);
      });

      test('are all visible after 2 clicked', () async {
        _bloc.clicks.add(2);
        drainStream(_bloc.gameState, 2);
        var _state = await _bloc.gameState.first;
        testAllTilesAreVisible(_state);
      });

      test('are randomly ordered', () async {
        testTilesAreRandomlyOrdered(_initialState);
      });
    });

    test('current number is 1', () async {
      testCurrentNumberIsOne(_bloc);
    });

    test("stopwatch is reset", () async {
      testStopwatchIsReset(_bloc);
    });

    test("game status is 'running'", () async {
      testGameStatusIsRunning(_bloc);
    });

    group('high-score ', () {
      test("is fetched", () async {
        verify(_mockRepo.fetchHighScore());
      });

      test("is not published when does not exist", () async {
        when(_mockRepo.fetchHighScore()).thenAnswer((_) => Future.value(null));

        _bloc = ChikChakBloc(
            stopwatch: MockStopwatch(),
            periodicRunner: (_, __) => {},
            scoreRepository: _mockRepo);

        expect(_bloc.highScore, emits("- - : - - . - - -"));
        // TODO: expect never emits anything else but "- - : - - . - -"
      });

      test("is published when exists", () async {
        expect(
            _bloc.highScore, emitsInOrder(["- - : - - . - - -", "02:51.017"]));
      });
    });
  });

  group('After restart ', () {
    group('tiles ', () {
      UnmodifiableListView<ChikChakTile> _afterRestartState;
      setUp(() async {
        _bloc.clicks.add(1);
        _bloc.clicks.add(2);
        _bloc.restarts.add(null);
        await drainStream(_bloc.gameState, 3);
        _afterRestartState = await _bloc.gameState.first;
      });

      test('are all visible', () async {
        testAllTilesAreVisible(_afterRestartState);
      });

      test('are randomly ordered', () async {
        testTilesAreRandomlyOrdered(_afterRestartState);
      });
    });

    test('current number is 1', () async {
      testCurrentNumberIsOne(_bloc);
    });

    test("stopwatch is reset", () async {
      testStopwatchIsReset(_bloc);
    });

    test("game status is 'running'", () async {
      testGameStatusIsRunning(_bloc);
    });
  });

  group("After 1, 3 is clicked ", () {
    setUp(() async {
      _bloc.clicks.add(1);
      await drainStream(_bloc.gameState, 1);
      await _timerCallback(null);
      _bloc.clicks.add(3);
      await drainStream(_bloc.gameState, 1);
    });

    test("only 1 is invisible", () async {
      var _nonVisibleTilesNumStream = _bloc.gameState
          .map((list) => list.where((tile) => !tile.visible))
          .map((list) => list.map((tile) => tile.num));

      expect(_nonVisibleTilesNumStream, emits([1]));
    });

    test("current number is incremented to 2", () async {
      expect(_bloc.curNum, emits(2));
    });

    test("stopwatch is running", () async {
      var count = 0;
      _bloc.curStopwatch.listen(expectAsync1((curStopwatch) async {
        expect(curStopwatch, contains(count.toString()));
        count++;
        if (count < 10) await _timerCallback(null);
      }, count: 10));
    });
  });

  group("After all tiles are clicked ", () {
    const score = Duration(minutes: 2, seconds: 51, milliseconds: 20);
    setUp(() async {
      when(_fastStopwatch.elapsed).thenReturn(score);
      clickAllTiles(_bloc.clicks);
      await drainStream(_bloc.gameState, 1 + ChikChakBloc.TILES_COUNT);
    });

    test("they are invisible", () async {
      var _gameVisibilityStateStream =
          _bloc.gameState.map((list) => list.map((tile) => tile.visible));

      expect(_gameVisibilityStateStream, emits(everyElement(false)));
    });

    test("game status is 'finished'", () async {
      expect(_bloc.gameStatus, emits(GameStatus.finished));
    });

    test("stopwatch is stopped", () async {
      verify(_fastStopwatch.stop());
    });

    group('high-score ', () {
      test("neither is stored nor is published if lower than cur", () async {},
          skip: "TODO");

      test("is stored if higher than current", () async {
        verify(_mockRepo.storeHighScore(score.inMilliseconds));
      });

      test("is published if higher than currrent", () async {
        expect(_bloc.highScore, emitsInOrder([anything, "02:51.020"]));
      });
    });
  });
}

void clickAllTiles(Sink<int> clicks) {
  List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1).forEach((i) {
    clicks.add(i);
  });
}

Future<void> drainStream(Stream stream, int count) async {
  var _count = 0;
  await for (var _ in stream) {
    if (++_count == count) {
      break;
    }
  }
}

void testAllTilesAreVisible(UnmodifiableListView<ChikChakTile> _initialState) {
  var _initialVisibilityState = _initialState.map((tile) => tile.visible);

  expect(_initialVisibilityState, everyElement(true));
}

void testTilesAreRandomlyOrdered(
    UnmodifiableListView<ChikChakTile> _initialState) {
  final _orderedNumList = List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1);
  var _initialNumList = _initialState.map((tile) => tile.num);

  expect(_initialNumList, isNot(orderedEquals(_orderedNumList)));
}

void testGameStatusIsRunning(ChikChakBloc _bloc) {
  expect(_bloc.gameStatus, emits(GameStatus.running));
}

void testStopwatchIsReset(ChikChakBloc _bloc) {
  expect(_bloc.curStopwatch, emits("00:00.000"));
}

void testCurrentNumberIsOne(ChikChakBloc _bloc) =>
    expect(_bloc.curNum, emits(1));
