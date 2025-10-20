import 'dart:math';

import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:flutter/services.dart' show rootBundle;

class SpotifyService {
  int currentSongIndex = -1;
  String cliendID = "28cb945996d04097b8b516575cc6322a";
  String redirectUrl = "hipsterclone://callback";
  String _token = 'NONE';

  Future<bool> resumeSong() async {
    await WebApiService().ensureActiveDevice(force: true);
    return await WebApiService().resumePlayback();
  }

  Future<bool> skipSong() async {
    await WebApiService().ensureActiveDevice(force: true);
    return await WebApiService().skipToNext();
  }

  Future<bool> playSong(String trackUri) async {
    await WebApiService().ensureActiveDevice(force: true);
    final ok = await WebApiService().startPlaybackWithUris([trackUri]);
    if (ok) {
      _lastPlayedSongUri = trackUri;
    }
    return ok;
  }

  Future<void> pauseSong() async {
    await WebApiService().ensureActiveDevice(force: true);
    await WebApiService().pausePlayback();
  }

  String? _lastPlayedSongUri;
  bool _repeatLastSong = false;

  Future<Track?> playRandomSong() async {
    await WebApiService().ensureActiveDevice(force: true);

    try {
      final list = Logicservice().trackYetToPlay;
      if (list.isEmpty) {
        print("No tracks left to play.");
        return null;
      }
      final random = Random();
      final nextTrack = list[random.nextInt(list.length)];
      final played = await playSong(nextTrack.uri);
      if (played) {
        Logicservice().removeTrackYetToplay(nextTrack);
        print(nextTrack.name);
        return nextTrack;
      } else {
        print("Failed to start playback for ${nextTrack.name}");
        return null;
      }
    } catch (e) {
      print("Error playing random song: $e");
      return null;
    }
  }
}
