import 'package:flutter/services.dart';

class MusicKit {
  static const _channel = MethodChannel('music_kit_channel');

  static Future<void> authorize() async {
    await _channel.invokeMethod('authorize');
  }

  static Future<void> playSong(String catalogId) async {
    await _channel.invokeMethod('playSong', {'id': catalogId});
  }

  static Future<void> playSongByMetadata(String title, String artist) async {
    await _channel.invokeMethod('playSongByMetadata', {
      'title': title,
      'artist': artist,
    });
  }

  static Future<String?> getPlayableId(String title, String artist) async {
    final res = await _channel.invokeMethod('getPlayableId', {
      'title': title,
      'artist': artist,
    });
    return res as String?;
  }

  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  static Future<void> resume() async {
    await _channel.invokeMethod('resume');
  }

  static Future<void> next() async {
    await _channel.invokeMethod('next');
  }

  static Future<void> previous() async {
    await _channel.invokeMethod('previous');
  }

  static Future<List<dynamic>> getUserPlaylists() async {
    final result = await _channel.invokeMethod('getUserPlaylists');
    return result as List<dynamic>;
  }

  static Future<List<dynamic>> getUserSongs() async {
    final result = await _channel.invokeMethod('getUserSongs');
    return result as List<dynamic>;
  }

  static Future<List<dynamic>> getPlaylistSongs(String playlistId) async {
    final result = await _channel.invokeMethod('getPlaylistSongs', {
      'id': playlistId,
    });
    return result as List<dynamic>;
  }

  static Future<List<dynamic>> searchCatalogPlaylists(String term) async {
    final result = await _channel.invokeMethod('searchCatalogPlaylists', {
      'term': term,
    });
    return result as List<dynamic>;
  }
}
