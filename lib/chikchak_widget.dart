import 'package:chik_chak/chikchak_bloc.dart';
import 'package:flutter/material.dart';

class ChikChakGame extends StatefulWidget {
  final ChikChakBloc _bloc;

  ChikChakGame(this._bloc, {Key key}) : super(key: key);

  @override
  ChikChakGameState createState() => ChikChakGameState(_bloc);
}

class ChikChakGameState extends State<ChikChakGame> {
  ChikChakBloc _bloc;

  ChikChakGameState(this._bloc);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        StreamBuilder(
            stream: _bloc.gameState,
            builder: (BuildContext context,
                AsyncSnapshot<List<ChikChakTile>> snapshot) {
              return GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 5,
                children: snapshot.data.map((tile) {
                  if (tile.visible) {
                    return GestureDetector(
                      onTap: () {
                        _bloc.clicks.add(tile.num);
                      },
                      child: Tile(Text('${tile.num}')),
                    );
                  } else {
                    return Container();
                  }
                }).toList(),
              );
            }),
        Positioned(
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Tile(
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: _bloc.curNum,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) =>
                              Text(
                                "Current: ${snapshot.data}",
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 25),
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: _bloc.curStopwatch,
                      builder: (BuildContext context,
                              AsyncSnapshot<Duration> snapshot) =>
                          Text(
                            "Time: ${snapshot.data}",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 25),
                          ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}

class Tile extends StatelessWidget {
  final child;

  const Tile(this.child, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}
