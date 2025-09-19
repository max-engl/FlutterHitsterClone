import 'package:flutter/material.dart';
import 'package:spotify_sdk/spotify_sdk.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  bool _connected = false;
  Future<void> connectToSpotify() async {
    try {
      var result = await SpotifySdk.connectToSpotifyRemote(
        clientId: '28cb945996d04097b8b516575cc6322a',
        redirectUrl:
            'hipsterclone://callback', // muss im Spotify Dashboard eingetragen sein
      );
      setState(() {
        _connected = result;
      });
    } catch (e) {
      debugPrint("Fehler beim Connect: $e");
    }
  }

  Future<void> skipSong() async {
    try {
      await SpotifySdk.skipNext();
    } catch (e) {
      debugPrint("Fehler beim Abspielen: $e");
    }
  }

  Future<void> playSong(String trackUri) async {
    try {
      await SpotifySdk.play(spotifyUri: trackUri);
    } catch (e) {
      debugPrint("Fehler beim Abspielen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Connected : " + _connected.toString()),
          ElevatedButton(
            onPressed: () => connectToSpotify(),
            child: Text("Connect to Spotify"),
          ),
          ElevatedButton(onPressed: () => skipSong(), child: Text("Skip Song")),
        ],
      ),
    );
  }
}
