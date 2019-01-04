import 'package:chik_chak/chikchak_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('Tiles ', () {
    ChikChakBloc _bloc;
    setUp(() {
      _bloc = ChikChakBloc();
    });

    test('are all visible', () async {
      final _initialState = await _bloc.gameState.first;
      var _initialVisibilityState = _initialState.map((tile) => tile.visible);

      expect(_initialVisibilityState, everyElement(equals(true)));
    });

    test('are randomly ordered', () async {
      final _initialState = await _bloc.gameState.first;
      final _orderedNumList =
          List.generate(ChikChakBloc.TILES_COUNT, (i) => i + 1);
      var _initialNumList = _initialState.map((tile) => tile.num);

      expect(_initialNumList, isNot(orderedEquals(_orderedNumList)));
    });
  });
}
