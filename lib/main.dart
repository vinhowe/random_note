import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';

import 'package:flutter/services.dart' show rootBundle;

import 'package:path_provider/path_provider.dart';


void main() => runApp(new RandomNote());

class RandomNote extends StatelessWidget {
  // This widget is the root of your application.
  Color awesomeBlue = new Color(0xFF195FFF);

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Random Note',
      theme: ThemeData.dark().copyWith(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primaryColor: awesomeBlue,
        backgroundColor: awesomeBlue,
        canvasColor: awesomeBlue,
        scaffoldBackgroundColor: awesomeBlue
      ),
      home: new RandomNotePage(title: 'Random Note'),
    );
  }
}

class RandomNotePage extends StatefulWidget {
  RandomNotePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<RandomNotePage> {
  List<String> _currentPossibleNotes = "ABCDEFG".split("");

  String _currentNote = "";

  String _lastNote = "";

  AudioPlayer audioPlayer = new AudioPlayer();

  HashMap<String, String> _paths;

  bool isShowingNote = false;

  void _playRandomNote() {
    setState(() {
      isShowingNote = false;
      _lastNote = _currentNote;
      while(_currentNote == _lastNote) {
        _currentNote = _currentPossibleNotes[new Random().nextInt(
            _currentPossibleNotes.length)];
      }
      play();
    });
  }

  void initState() {
    loadNotes();
    super.initState();
  }

  Future<void> loadNotes() async {
    _paths = new HashMap();
    for(String character in _currentPossibleNotes) {
      final file = new File('${(await getTemporaryDirectory()).path}/$character.mp3');
      await file.writeAsBytes((await rootBundle.load('assets/notes/$character.mp3')).buffer.asUint8List());
      _paths[character] = file.path;
    }
    return;
  }

  Future<void> play() {
    //await audioPlayer.play("./notes/A.mp3").catchError((error) => print(error)).then((result) => audioPlayer.stop());
    if(audioPlayer.state == AudioPlayerState.PLAYING) {
      audioPlayer.stop();
    }
    return audioPlayer.play(_paths[_currentNote], isLocal: true);
    //setState(() => playerState = PlayerState.playing);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle bigButtonStyle = Theme.of(context).textTheme.display1.copyWith(color: Colors.white);
    TextStyle bigBlackNoteStyle = Theme.of(context).textTheme.display2.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 100.0);

    return new Scaffold(
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new FlatButton(child: Text("Play note", style: bigButtonStyle,), onPressed: () => _playRandomNote()),
            new FlatButton(child: Text("Reveal", style: bigButtonStyle,), onPressed: () {setState(() {
              isShowingNote = !isShowingNote;
            });}),
            new Opacity(opacity: isShowingNote ? 1.0 : 0.0, child: new Text(_currentNote, style: bigBlackNoteStyle,))
          ],
        ),
      ),
    );
  }
}
