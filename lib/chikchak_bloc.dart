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
      updateState(numClicked);
    });
  }

  Sink<int> get clicks => _clicksController.sink;

  Stream<UnmodifiableListView<ChikChakTile>> get gameState =>
      _gameStateSubject.stream;

  void dispose() {
    _clicksController.close();
    _gameStateSubject.close();
  }

  void updateState(int numClicked) {
    if (numClicked == _curNum) {
      print('User clicked on $numClicked.');
      _curState[_num2index[numClicked]].visible = false;
      _curNum++;
      _gameStateSubject.add(UnmodifiableListView(_curState));
    }
  }

  static shuffle(List<ChikChakTile> items) {
    var random = new Random();

    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);

      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }

    return items;
  }
}

class ChikChakTile {
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
