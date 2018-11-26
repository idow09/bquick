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
      initialData: [ChikChakTile(1, true), ChikChakTile(2, true)],
      // Should be [true x 49]
      builder:
          (BuildContext context, AsyncSnapshot<List<ChikChakTile>> snapshot) {
        final curState = snapshot.data;

        // should build a table widget using the state (List<bool>)

        return Scaffold(
          appBar: AppBar(
            title: Text("Let's Play ChikChak!"),
          ),
          body: Text(
            "Hi there from ChikChak\nThe state is $curState",
            style: TextStyle(color: Colors.white),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  bloc.clicks.add(7)), // should be the number of this tile
        );
      },
    );
  }
}
