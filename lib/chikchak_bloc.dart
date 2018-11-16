import 'dart:async';

import 'package:rxdart/rxdart.dart';

class ChikChakBloc {
  final Sink<int> onPressed;
  final Stream<List<bool>> state;

  factory ChikChakBloc() {
    final onPressed = PublishSubject<int>();

    final state = onPressed
        // explanation
        .map((i) => [true])
        // explanation
        .startWith([true]);

    return ChikChakBloc._(onPressed, state);
  }

  ChikChakBloc._(this.onPressed, this.state);

  void dispose() {
    onPressed.close();
  }
}
