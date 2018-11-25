import 'dart:async';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  final Sink<int> onPressed;
  final Stream<List<bool>> stateStream;

  final List<bool> state = [true, true];

  factory ChikChakBloc() {
    final onPressed = PublishSubject<int>();

    final state = onPressed
        // explanation
        .map((i) => [true, false])
        // explanation
        .startWith([true, true]);

    return ChikChakBloc._(onPressed, state);
  }

  ChikChakBloc._(this.onPressed, this.stateStream);

  void dispose() {
    onPressed.close();
  }
}
