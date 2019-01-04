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
      final _firstCurNum = await _bloc.curNum.first;

      expect(_firstCurNum, equals(1));
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
      var _curNum = await _bloc.curNum.first;
      expect(_curNum, equals(2));
    });
  });
}
