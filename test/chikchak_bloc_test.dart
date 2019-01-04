//import 'package:mockito/mockito.dart';
import 'package:chik_chak/chikchak_bloc.dart';
import 'package:test/test.dart';

void main() {
  group('Tiles ', () {
    test('are all visible', () async {
      final _bloc = ChikChakBloc();
      final initialState = await _bloc.gameState.first;
      expect(
          initialState.map((tile) => tile.visible), everyElement(equals(true)));
    });
  });
}
