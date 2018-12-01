import 'package:chik_chak/chikchak_bloc.dart';
import 'package:flutter/material.dart';

// The View in a Stream-based architecture takes two arguments: The State Stream
// and the onTextChanged callback. In our case, the onTextChanged callback will
// emit the latest String to a Stream<String> whenever it is called.
//
// The State will use the Stream<String> to send new search requests to the
// GithubApi.
class ChikChakGame extends StatefulWidget {
  ChikChakGame({Key key}) : super(key: key);

  @override
  ChikChakGameState createState() => ChikChakGameState();
}

class ChikChakGameState extends State<ChikChakGame> {
  ChikChakBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = ChikChakBloc();
  }

  @override
  void dispose() {
    bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ChikChakTile>>(
      stream: bloc.gameState,
      initialData: List.generate(9, (i) => ChikChakTile(i, true)),
      builder:
          (BuildContext context, AsyncSnapshot<List<ChikChakTile>> snapshot) {
        if (snapshot.hasData) {
          final _curState = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text("Let's Play ChikChak!"),
            ),
            body: GridView.count(
              // Create a grid with 2 columns. If you change the scrollDirection to
              // horizontal, this would produce 2 rows.
              crossAxisCount: 3,
              // Generate 100 Widgets that display their index in the List
              children: List.generate(9, (index) {
                return GestureDetector(
                  child: Center(
                    child: Text(
                      '${_curState[index]}',
                      style: Theme.of(context).textTheme.headline,
                    ),
                  ),
                  onTap: () {
                    bloc.clicks.add(index);
                  },
                );
              }),
            ),
          );
        }
      },
    );
  }
}
