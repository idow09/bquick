import 'package:chik_chak/chikchak_bloc.dart';
import 'package:chik_chak/chikchak_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(ChikChakApp());
}

class ChikChakApp extends StatefulWidget {
  ChikChakApp({Key key}) : super(key: key);

  @override
  _ChikChakAppState createState() => _ChikChakAppState();
}

class _ChikChakAppState extends State<ChikChakApp> {
  ChikChakBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ChikChakBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RxDart ChikChak',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Let's Play ChikChak!"),
        ),
        body: ChikChakGame(_bloc),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                onPressed: () => _bloc.restarts.add(null),
                child: Icon(Icons.refresh),
            tooltip: "Restart",
              ),
        ),
      ),
    );
  }
}
