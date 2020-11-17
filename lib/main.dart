import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/profile_content.dart';
import 'package:hello_me/suggestions_repository.dart';
import 'package:hello_me/user_repository.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<UserRepository>(
              create: (_) => UserRepository.instance()),
          ChangeNotifierProvider<SuggestionsRepository>(
              create: (_) => SuggestionsRepository.instance())
        ],
        child: MaterialApp(
            title: 'Startup Name Generator',
            theme: ThemeData(
              primaryColor: Colors.red,
            ),
            home: RandomWords()));
  }
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  final SnappingSheetController _snappingSheetController = SnappingSheetController();
  bool _blurEffect = false;

  Widget _buildSuggestions(SuggestionsRepository sug) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 100,
      itemBuilder: (BuildContext _context, int i) {
        if (i >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[i], sug);
      },
      separatorBuilder: (_, __) => Divider(),
    );
  }

  Widget _buildRow(WordPair pair, SuggestionsRepository sug) {
    final alreadySaved = sug.saved?.contains(pair) ?? false;
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            sug.removePair(pair);
          } else {
            sug.addPair(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //final wordPair = WordPair.random(); // Delete these...
    //return Text(wordPair.asPascalCase); // ... two lines.

    return Consumer2(
        builder: (contex, UserRepository user, SuggestionsRepository sug, _) {
      return Scaffold(
        // Add from here...
        appBar: AppBar(
          title: Text('Startup Name Generator'),
          actions: [
            IconButton(
                icon: Icon(Icons.list),
                onPressed: () {
                  _pushSaved();
                }),
            ((user.status != Status.Authenticated)
                ? IconButton(
                    icon: Icon(Icons.login),
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute<void>(builder: (_) => Login()));
                    })
                : IconButton(
                    icon: Icon(Icons.exit_to_app),
                    onPressed: () {
                      user.signOut();
                    }))
          ],
        ),
        body: Builder(builder: (context) => user.status == Status.Authenticated
            ? SnappingSheet(
                sheetAbove: SnappingSheetContent(child: _buildSuggestions(sug)),
                sheetBelow: SnappingSheetContent(child: ProfileContent(userRepo: user, context: context)),
                lockOverflowDrag: true,
                snappingSheetController: _snappingSheetController,
                snapPositions: const [
                  SnapPosition(positionPixel: 0.0),
                  SnapPosition(positionFactor: 0.25)
                ],
                grabbing: InkWell(
                  onTap: () => {
                    if (_snappingSheetController.currentSnapPosition == _snappingSheetController.snapPositions.first) {
                      _snappingSheetController.snapToPosition(_snappingSheetController.snapPositions.last)
                    } else {
                      _snappingSheetController.snapToPosition(_snappingSheetController.snapPositions.first)
                    }
                  },
                  child: Container(
                    child: Row(children: [
                      Text(
                        "Welcome back, ${user.user.email}      ",
                        style: TextStyle(fontSize: 16),
                      ),
                      Icon(Icons.keyboard_arrow_up)
                    ]),
                    color: Colors.grey[300],
                    padding: EdgeInsets.all(20.0),
                  ),
                ),
              )
            : _buildSuggestions(sug)),
      );
    });
  }

  void _pushSaved() {
    final globalKey = GlobalKey<ScaffoldState>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Consumer2(builder:
              (context, UserRepository user, SuggestionsRepository sug, _) {
            final tiles = sug.saved.map(
              (WordPair pair) {
                return ListTile(
                  title: Text(
                    pair.asPascalCase,
                    style: _biggerFont,
                  ),
                  trailing: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        sug.removePair(pair);
                      }),
                );
              },
            );
            final divided = ListTile.divideTiles(
              context: context,
              tiles: tiles,
            ).toList();

            return Scaffold(
              key: globalKey,
              appBar: AppBar(
                title: Text('Saved Suggestions'),
              ),
              body: ListView(children: divided),
            );
          });
        },
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}
