import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  final _gameStateSubject = BehaviorSubject<
      UnmodifiableListView<ChikChakTile>>(); // add seedValue: initialGameState
  final _clicksController = StreamController<int>();

  final List<ChikChakTile> _curState =
      List.generate(9, (i) => ChikChakTile(i, true));

  ChikChakBloc() {
    _clicksController.stream.listen((numClicked) async {
      updateState(numClicked);
      _gameStateSubject.add(UnmodifiableListView(_curState));
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  Stream<List<ChikChakTile>> get gameState => _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _gameStateSubject.close();
  }

  void updateState(int index) {
    _curState[index].visible = false;
    print('updating state after $index has been pressed');
  }
}

class ChikChakTile {
  // final int index; ???
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

  ChikChakTile(this.num, this.visible);
}
