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
                crossAxisCount: ChikChakBloc.WIDTH,
                children: snapshot.data.map((tile) {
                  if (tile.visible) {
                    return GestureDetector(
                      onTap: () {
                        _bloc.clicks.add(tile.num);
                      },
                      child: Tile(child: Text('${tile.num}')),
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
              child: Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: _bloc.bestTime,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            return Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(Icons.arrow_upward),
                                ),
                                Text(
                                  "${snapshot.data}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 25),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder(
                          stream: _bloc.curStopwatch,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            return Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Icon(Icons.timer),
                                ),
                                Text(
                                  "${snapshot.data}",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 25),
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: _bloc.curNum,
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) =>
                              Text(
                                "# ${snapshot.data}",
                                textAlign: TextAlign.start,
                                style: TextStyle(fontSize: 25),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        StreamBuilder(
          stream: _bloc.gameStatus,
          builder: (BuildContext context, AsyncSnapshot<GameStatus> snapshot) {
            if (snapshot.data == GameStatus.finished) {
              return Center(
                child: Tile(
                    child: Column(
                  children: <Widget>[
                    Icon(
                      Icons.check,
                      size: 150,
                    ),
                    StreamBuilder(
                      stream: _bloc.curStopwatch,
                      builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) =>
                          Text(
                            "${snapshot.data}",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 25),
                          ),
                    ),
                  ],
                )),
              );
            } else {
              return Container();
            }
          },
        )
      ],
    );
  }
}

class Tile extends StatelessWidget {
  final child;

  const Tile({this.child, Key key}) : super(key: key);

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
