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

  final StreamController<bool> _restartClicksController =
  StreamController<bool>();

  ChikChakBloc() {
    _curState = shuffle(List.generate(25, (i) => ChikChakTile(i + 1, true)));
    _curNum = 1;

    _curState.asMap().forEach((i, tile) {
      _num2index[tile.num] = i;
    });

    _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
        seedValue: UnmodifiableListView(_curState));

    _clicksController.stream.listen((numClicked) async {
      handleClickEvent(numClicked);
    });

    _restartClicksController.stream.listen((click) async {
      restartGame();
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  Sink<bool> get restartClicks => _restartClicksController.sink;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _restartClicksController.close();
    _gameStateSubject.close();
  }

  void handleClickEvent(int numClicked) {
    print('User clicked on $numClicked.');
    if (numClicked == _curNum) {
      updateState(numClicked);
      publishNewState();
    }
  }

  void publishNewState() {
    _gameStateSubject.add(UnmodifiableListView(_curState));
  }

  void updateState(int numClicked) {
    _curState[_num2index[numClicked]].visible = false;
    _curNum++;
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

  void restartGame() {
    print("Restarting game.");
  }
}

class ChikChakTile {
  final int num;
  var visible;

  ChikChakTile(this.num, this.visible);
}
