import 'dart:math';
import 'package:hitsterclone/MusicKit.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';

class AppleMusicService {
  Future<bool> authorize() async {
    try {
      await MusicKit.authorize();
      Logicservice().setConnected(true);
      return true;
    } catch (_) {
      Logicservice().setConnected(false);
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchCatalogPlaylists(String term) async {
    final res = await MusicKit.searchCatalogPlaylists(term);
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getUserPlaylists() async {
    final res = await MusicKit.getUserPlaylists();
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPlaylistTracks(
    String playlistId,
  ) async {
    final res = await MusicKit.getPlaylistSongs(playlistId);
    return res.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Track>> getPlaylistTracksModel(String playlistId) async {
    final maps = await getPlaylistTracks(playlistId);
    final tracks = <Track>[];

    for (final m in maps) {
      final title = m['title'] as String? ?? 'UNKNOWN';
      final artist = m['artist'] as String? ?? 'Unknown';
      final album = m['album'] as String? ?? '';
      final image = m['imageUrl'] as String?;
      final isrc = m['isrc'] as String? ?? "";
      final libraryId = m['id'] as String? ?? "";

      String playableId = "";

      // 1. Prefer ISRC
      if (isrc.isNotEmpty) {
        playableId = isrc;
      } else {
        // 2. Fetch catalog ID via metadata
        final id = await MusicKit.getPlayableId(title, artist);
        if (id != null) playableId = id;
      }

      // 3. Fallback still empty → use metadata playback at runtime
      tracks.add(
        Track(
          id: playableId.isNotEmpty ? playableId : "$title|||$artist",
          name: title,
          artists: [artist],
          albumName: album,
          albumImageUrl: image,
          uri: playableId, // required for playback
          durationMs: 0,
        ),
      );
    }

    return tracks;
  }

  Future<bool> playSong(String idOrMeta) async {
    try {
      print("AM debug: playSong attempt id=$idOrMeta");

      // Case 1: real catalog ID
      if (!idOrMeta.contains("|||") && idOrMeta.isNotEmpty) {
        await MusicKit.playSong(idOrMeta);
        return true;
      }

      // Case 2: fallback metadata encoded in id
      final parts = idOrMeta.split("|||");
      if (parts.length == 2) {
        final title = parts[0];
        final artist = parts[1];
        await MusicKit.playSongByMetadata(title, artist);
        return true;
      }

      return false;
    } catch (e) {
      print("AM debug: playSong ERROR: $e");
      return false;
    }
  }

  Future<void> pauseSong() async {
    await MusicKit.pause();
  }

  Future<bool> resumeSong() async {
    try {
      await MusicKit.resume();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> skipSong() async {
    try {
      await MusicKit.next();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<Track?> playRandomSong() async {
    final list = Logicservice().trackYetToPlay;
    if (list.isEmpty) return null;

    final next = list[Random().nextInt(list.length)];
    print(next.uri);

    final ok = await playSong(next.uri);
    if (ok) {
      Logicservice().removeTrackYetToplay(next);
      return next;
    }
    return null;
  }
}
