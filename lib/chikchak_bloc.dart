import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  static final List<ChikChakTile> _initState =
      shuffle(List.generate(9, (i) => ChikChakTile(i + 1, true)));

  final _gameStateSubject = BehaviorSubject<UnmodifiableListView<ChikChakTile>>(
      seedValue: UnmodifiableListView(_initState));

  final _clicksController = StreamController<int>();

  final List<ChikChakTile> _curState = _initState;

  final Map<int, int> _num2index = Map();

  var _curNum = 1;

  ChikChakBloc() {
    _curState.asMap().forEach((i, t) {
      _num2index[t.num] = i;
    });

    _clicksController.stream.listen((numClicked) async {
      handleClickEvent(numClicked);
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _gameStateSubject.close();
  }

  void handleClickEvent(int numClicked) {
    if (numClicked == _curNum) {
      print('User clicked on $numClicked.');
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
}

class ChikChakTile {
  final int num;
  var visible;

  ChikChakTile(this.num, this.visible);
}
