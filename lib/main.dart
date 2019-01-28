import 'package:bquick/bquick_bloc.dart';
import 'package:bquick/bquick_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(BQuickApp());
}

class BQuickApp extends StatefulWidget {
  BQuickApp({Key key}) : super(key: key);

  @override
  _BQuickAppState createState() => _BQuickAppState();
}

class _BQuickAppState extends State<BQuickApp> {
  BQuickBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BQuickBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.orange),
      title: 'RxDart BQuick',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BQuick!'),
        ),
        body: BQuickGame(_bloc),
        floatingActionButton: Builder(
          builder: (BuildContext context) => FloatingActionButton(
                onPressed: () => _bloc.restarts.add(null),
                child: const Icon(Icons.refresh),
                tooltip: 'Restart',
              ),
        ),
      ),
    );
  }
}
