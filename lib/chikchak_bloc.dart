import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  List<ChikChakTile> _curState;

  int _curNum;

  final Map<int, int> _num2index = Map();

  BehaviorSubject<UnmodifiableListView<ChikChakTile>> _gameStateSubject;

  final StreamController<int> _clicksController = StreamController<int>();

  final StreamController<bool> _restartsController = StreamController<bool>();

  ChikChakBloc() {
    resetState();

    _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
        seedValue: UnmodifiableListView(_curState));

    _clicksController.stream.listen((numClicked) async {
      handleClickEvent(numClicked);
    });

    _restartsController.stream.listen((restartEvent) async {
      restartGame();
    });
  }

  void resetState() {
    _curState = shuffle(List.generate(25, (i) => ChikChakTile(i + 1, true)));
    _curNum = 1;

    _curState.asMap().forEach((i, tile) {
      _num2index[tile.num] = i;
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  Sink<bool> get restarts => _restartsController.sink;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _restartsController.close();
    _gameStateSubject.close();
  }

  void handleClickEvent(int numClicked) {
    print('User clicked on $numClicked.');
    if (numClicked == _curNum) {
      updateState(numClicked);
      publishState();
    }
  }

  void updateState(int numClicked) {
    _curState[_num2index[numClicked]].visible = false;
    _curNum++;
  }

  void publishState() {
    _gameStateSubject.add(UnmodifiableListView(_curState));
  }

  void restartGame() {
    print("Restarting game.");
    resetState();
    publishState();
  }

  static shuffle(List<ChikChakTile> tiles) {
    var random = new Random();

    for (var i = tiles.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = tiles[i];
      tiles[i] = tiles[n];
      tiles[n] = temp;
    }

    return tiles;
  }
}

class ChikChakTile {
  final int num;
  var visible;

  ChikChakTile(this.num, this.visible);
}
