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
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Let's Play ChikChak!"),
        ),
        body: ChikChakGame(_bloc),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton(
                onPressed: () {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text("Restarting game!"),
                    duration: Duration(seconds: 1),
                  ));
                  _bloc.restartClicks.add(true);
                },
                child: Icon(Icons.refresh),
              ),
        ),
      ),
    );
  }
}
