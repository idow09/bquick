import 'dart:collection';

import 'package:chik_chak/chikchak_bloc.dart';
import 'package:test/test.dart';

void main() {
  ChikChakBloc _bloc;
  setUp(() {
    _bloc = ChikChakBloc();
  });

  group('In initial state ', () {
    group('tiles ', () {
      UnmodifiableListView<ChikChakTile> _initialState;
      setUp(() async => _initialState = await _bloc.gameState.first);

      test('are all visible', () async {
        testAllTilesAreVisible(_initialState);
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
  });

  group('After restart ', () {
    group('tiles ', () {
      UnmodifiableListView<ChikChakTile> _initialState;
      setUp(() async {
        await Future(() async {
          _bloc.clicks.add(1);
          _bloc.clicks.add(2);
          _bloc.restarts.add(null);
        });
        _initialState = await _bloc.gameState.first;
      });

      test('are all visible', () async {
        testAllTilesAreVisible(_initialState);
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
  });

  group("After 1 is clicked ", () {
    setUp(() {
      _bloc.clicks.add(1);
    });

    test("only 1 is invisible", () async {
      var _nonVisibleTilesNumStream = _bloc.gameState
          .map((list) => list.where((tile) => !tile.visible))
          .map((list) => list.map((tile) => tile.num));

      expect(_nonVisibleTilesNumStream, emits(equals([1])));
    });

    test("current number is incremented", () async {
      expect(_bloc.curNum, emits(2));
    });

    test("stopwatch is running", () async {
      var zero = equals("00:00.000");
      var nonZero = isNot(zero);
      // test that stopwatch is constantly emitting time strings
      expect(_bloc.curStopwatch, emitsInOrder([zero, nonZero, nonZero]));
    });
  });

  group("After all tiles are clicked ", () {
    setUp(() async {
      clickAllTiles(_bloc.clicks);
      await drainStateStream(_bloc.gameState);
    });

    test("they are invisible", () async {
      var _gameVisibilityStateStream =
          _bloc.gameState.map((list) => list.map((tile) => tile.visible));

      expect(_gameVisibilityStateStream, emits(everyElement(equals(false))));
    });

    test("game status is 'finished'", () async {
      expect(_bloc.gameStatus, emits(equals(GameStatus.finished)));
    });
  });
}

void clickAllTiles(Sink<int> _clicks) {
  List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1).forEach((i) {
    _clicks.add(i);
  });
}

Future<void> drainStateStream(Stream _stream) async {
  var _count = 0;
  await for (var _ in _stream) {
    if (++_count == ChikChakBloc.TILES_COUNT + 1) {
      break;
    }
  }
}

void testAllTilesAreVisible(UnmodifiableListView<ChikChakTile> _initialState) {
  var _initialVisibilityState = _initialState.map((tile) => tile.visible);

  expect(_initialVisibilityState, everyElement(equals(true)));
}

void testTilesAreRandomlyOrdered(
    UnmodifiableListView<ChikChakTile> _initialState) {
  final _orderedNumList = List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1);
  var _initialNumList = _initialState.map((tile) => tile.num);

  expect(_initialNumList, isNot(orderedEquals(_orderedNumList)));
}

void testGameStatusIsRunning(ChikChakBloc _bloc) {
  expect(_bloc.gameStatus, emits(equals(GameStatus.running)));
}

void testStopwatchIsReset(ChikChakBloc _bloc) {
  expect(_bloc.curStopwatch, emits(equals("00:00.000")));
}

void testCurrentNumberIsOne(ChikChakBloc _bloc) =>
    expect(_bloc.curNum, emits(1));
