import 'dart:async';
import 'dart:collection';

import 'package:bquick/bquick_bloc.dart';
import 'package:bquick/score_repository.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockStopwatch extends Mock implements Stopwatch {}

class MockScoreRepository extends Mock implements ScoreRepository {}

void main() {
  BQuickBloc _bloc;
  Function _timerCallback;

  final ScoreRepository _mockRepo = MockScoreRepository();
  final Stopwatch _fastStopwatch = MockStopwatch();

  setUp(() {
    int counter = 0;
    when(_fastStopwatch.elapsed)
        .thenAnswer((_) => Duration(seconds: counter++));

    final Function _fastRunner = (Duration _, Function c) {
      _timerCallback = c;
      return null;
    };
    when(_mockRepo.fetchHighScore()).thenAnswer((_) => Future<int>.value(
        const Duration(minutes: 2, seconds: 51, milliseconds: 17)
            .inMilliseconds));

    _bloc = BQuickBloc(
        stopwatch: _fastStopwatch,
        periodicRunner: _fastRunner,
        scoreRepository: _mockRepo);
  });

  group('In initial state ', () {
    group('tiles ', () {
      UnmodifiableListView<BQuickTile> _initialState;
      setUp(() async => _initialState = await _bloc.gameState.first);

      test('are all visible', () async {
        testAllTilesAreVisible(_initialState);
      });

      test('are all visible after 2 clicked', () async {
        _bloc.clicks.add(2);
        drainStream(_bloc.gameState, 2);
        final UnmodifiableListView<BQuickTile> _state =
            await _bloc.gameState.first;
        testAllTilesAreVisible(_state);
      });

      test('are randomly ordered', () async {
        testTilesAreRandomlyOrdered(_initialState);
      });
    });

    test('current number is 1', () async {
      testCurrentNumberIsOne(_bloc);
    });

    test('stopwatch is reset', () async {
      testStopwatchIsReset(_bloc);
    });

    test("game status is 'running'", () async {
      testGameStatusIsRunning(_bloc);
    });

    group('high-score ', () {
      test('is fetched', () async {
        verify(_mockRepo.fetchHighScore());
      });

      test('is not published when does not exist', () async {
        when(_mockRepo.fetchHighScore())
            .thenAnswer((_) => Future<int>.value(null));

        _bloc = BQuickBloc(
            stopwatch: MockStopwatch(),
            periodicRunner: (Duration _, Function __) {},
            scoreRepository: _mockRepo);

        expect(_bloc.highScore, emits('- - : - - . - -'));
        // TODO(idow09): expect never emits anything else but "- - : - - . - -", https:// issue
      });

      test('is published when exists', () async {
        expect(_bloc.highScore,
            emitsInOrder(<String>['- - : - - . - -', '02:51.01']));
      });
    });
  });

  group('After restart ', () {
    group('tiles ', () {
      UnmodifiableListView<BQuickTile> _afterRestartState;
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

    test('stopwatch is reset', () async {
      testStopwatchIsReset(_bloc);
    });

    test("game status is 'running'", () async {
      testGameStatusIsRunning(_bloc);
    });
  });

  group('After 1, 3 is clicked ', () {
    setUp(() async {
      _bloc.clicks.add(1);
      await drainStream(_bloc.gameState, 1);
      await _timerCallback(null);
      _bloc.clicks.add(3);
      await drainStream(_bloc.gameState, 1);
    });

    test('only 1 is invisible', () async {
      final Stream<Iterable<int>> _nonVisibleTilesNumStream = _bloc.gameState
          .map((UnmodifiableListView<BQuickTile> list) =>
              list.where((BQuickTile tile) => !tile.visible))
          .map((Iterable<BQuickTile> list) =>
              list.map((BQuickTile tile) => tile.value));

      expect(_nonVisibleTilesNumStream, emits(<int>[1]));
    });

    test('current number is incremented to 2', () async {
      expect(_bloc.curNum, emits(2));
    });

    test('stopwatch is running', () async {
      int count = 0;
      _bloc.curStopwatch.listen(expectAsync1((String curStopwatch) async {
        expect(curStopwatch, contains(count.toString()));
        count++;
        if (count < 10) {
          await _timerCallback(null);
        }
      }, count: 10));
    });
  });

  group('After all tiles are clicked ', () {
    const Duration BETTER_SCORE =
        Duration(minutes: 2, seconds: 51, milliseconds: 12);
    setUp(() async {
      when(_fastStopwatch.elapsed).thenReturn(BETTER_SCORE);
      clickAllTiles(_bloc.clicks);
      await drainStream(_bloc.gameState, 1 + BQuickBloc.TILES_COUNT);
    });

    test('they are invisible', () async {
      final Stream<Iterable<bool>> _gameVisibilityStateStream = _bloc.gameState
          .map((UnmodifiableListView<BQuickTile> list) =>
              list.map((BQuickTile tile) => tile.visible));

      expect(_gameVisibilityStateStream, emits(everyElement(false)));
    });

    test("game status is 'finished'", () async {
      expect(_bloc.gameStatus, emits(GameStatus.finished));
    });

    test('stopwatch is stopped', () async {
      verify(_fastStopwatch.stop());
    });

    group('high-score ', () {
      test('neither is stored nor is published if lower than cur', () async {},
          skip: 'TODO');

      test('is stored if higher than current', () async {
        verify(_mockRepo.storeHighScore(BETTER_SCORE.inMilliseconds));
      });

      test('is published if higher than currrent', () async {
        expect(_bloc.highScore, emitsInOrder(<dynamic>[anything, '02:51.01']));
      });
    });
  });
}

void clickAllTiles(Sink<int> clicks) {
  List<int>.generate(BQuickBloc.TILES_COUNT, (int i) => i + 1)
      .forEach((int i) => clicks.add(i));
}

Future<void> drainStream(
    Stream<UnmodifiableListView<BQuickTile>> stream, int count) async {
  int _count = 0;
  await for (UnmodifiableListView<BQuickTile> _ in stream) {
    if (++_count == count) {
      break;
    }
  }
}

void testAllTilesAreVisible(UnmodifiableListView<BQuickTile> _initialState) {
  final UnmodifiableListView<bool> _initialVisibilityState =
      _initialState.map((BQuickTile tile) => tile.visible);

  expect(_initialVisibilityState, everyElement(true));
}

void testTilesAreRandomlyOrdered(
    UnmodifiableListView<BQuickTile> _initialState) {
  final List<int> _orderedNumList =
      List<int>.generate(BQuickBloc.TILES_COUNT, (int i) => i + 1);
  final List<int> _initialNumList =
      _initialState.map((BQuickTile tile) => tile.value);

  expect(_initialNumList, isNot(orderedEquals(_orderedNumList)));
}

void testGameStatusIsRunning(BQuickBloc _bloc) {
  expect(_bloc.gameStatus, emits(GameStatus.running));
}

void testStopwatchIsReset(BQuickBloc _bloc) {
  expect(_bloc.curStopwatch, emits('00:00.00'));
}

void testCurrentNumberIsOne(BQuickBloc _bloc) => expect(_bloc.curNum, emits(1));
