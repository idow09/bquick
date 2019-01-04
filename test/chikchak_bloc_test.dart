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
        var _initialVisibilityState = _initialState.map((tile) => tile.visible);

        expect(_initialVisibilityState, everyElement(equals(true)));
      });

      test('are randomly ordered', () async {
        final _orderedNumList =
            List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1);
        var _initialNumList = _initialState.map((tile) => tile.num);

        expect(_initialNumList, isNot(orderedEquals(_orderedNumList)));
      });
    });

    test('current number is 1', () async {
      expect(_bloc.curNum, emits(1));
    });

    test("game status is 'running'", () async {
      expect(_bloc.gameStatus, emits(equals(GameStatus.running)));
    });
  });

  group("After 1 is clicked ", () {
    setUp(() {
      _bloc.clicks.add(1);
    });

    test("it's no longer visible", () async {
      var _state = await _bloc.gameState.first;
      expect(_state.where((tile) => tile.num == 1).map((tile) => tile.visible),
          equals([false]));
    });

    test("current number is incremented", () async {
      expect(_bloc.curNum, emits(2));
    });
  });

  group("After all numbers are clicked ", () {
    setUp(() async {
      List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1).forEach((i) {
        _bloc.clicks.add(i);
      });
      await Future.delayed(Duration(milliseconds: 100));
    });

    test("all tiles are invisible", () async {
      var _visibilityState =
          (await _bloc.gameState.first).map((tile) => tile.visible);

      expect(_visibilityState, everyElement(equals(false)));
    });

    test("game status is 'finished'", () async {
      expect(_bloc.gameStatus, emits(equals(GameStatus.finished)));
    });
  });
}
