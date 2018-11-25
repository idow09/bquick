import 'dart:async';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  final Sink<int> onPressed;
  final Stream<List<ChikChakTile>> stateStream;

  final List<ChikChakTile> state = [
    ChikChakTile(1, true),
    ChikChakTile(2, true)
  ];

  factory ChikChakBloc() {
    final onPressed = PublishSubject<int>();

    final state = onPressed
        // explanation
        .map((i) => [ChikChakTile(1, false), ChikChakTile(2, true)])
        // explanation
        .startWith([ChikChakTile(1, true), ChikChakTile(2, true)]);

    return ChikChakBloc._(onPressed, state);
  }

  ChikChakBloc._(this.onPressed, this.stateStream);

  void dispose() {
    onPressed.close();
  }
}

class ChikChakTile {
  final int num;
  final bool visible;

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
