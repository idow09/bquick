import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  static final UnmodifiableListView<ChikChakTile> _initUnmodifiableState =
      UnmodifiableListView(List.generate(9, (i) => ChikChakTile(i, i, true)));

  final _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
      seedValue: _initUnmodifiableState);

  final _clicksController = StreamController<int>();

  final List<ChikChakTile> _curState = _initUnmodifiableState;

  ChikChakBloc() {
    _clicksController.stream.listen((numClicked) async {
      updateState(numClicked);
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  UnmodifiableListView<ChikChakTile> get gameInitialState =>
      _initUnmodifiableState;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _gameStateSubject.close();
  }

  void updateState(int numClicked) {
    _curState[numClicked].visible = false;
    print('Updating state after $numClicked has been pressed');
    _gameStateSubject.add(UnmodifiableListView(_curState));
  }
}

class ChikChakTile {
  final int index;
  final int num;
  var visible;

  @override
  String toString() {
    if (visible) {
      return "[ $num ]";
    } else {
      return "[($num)]";
    }
  }

  ChikChakTile(this.index, this.num, this.visible);
}
