import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hitsterclone/MusicKit.dart';
import 'package:hitsterclone/services/AppleMusicService.dart';
import 'package:hitsterclone/services/LogicService.dart';

void main() {
  const channel = MethodChannel('music_kit_channel');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'authorize':
          return 'authorized';
        case 'searchCatalogPlaylists':
          return [
            {'id': 'pl.1', 'name': 'Top Hits', 'imageUrl': 'http://img'},
          ];
        case 'getUserPlaylists':
          return [
            {'id': 'lib.1', 'name': 'My List', 'description': ''},
          ];
        case 'getPlaylistSongs':
          return [
            {'id': 'song.1', 'title': 'Track', 'artist': 'Artist', 'album': ''},
          ];
        case 'playSong':
          return 'playing';
      }
      return null;
    });
  });

  tearDown(() {
    ServicesBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('AppleMusic authorize sets connected', () async {
    final ok = await AppleMusicService().authorize();
    expect(ok, isTrue);
    expect(Logicservice().connected, isTrue);
  });

  test('Search catalog playlists normalizes maps', () async {
    final res = await AppleMusicService().searchCatalogPlaylists('hits');
    expect(res, isNotEmpty);
    expect(res.first['id'], 'pl.1');
    expect(res.first['name'], 'Top Hits');
  });

  test('Get user playlists normalizes maps', () async {
    final res = await AppleMusicService().getUserPlaylists();
    expect(res, isNotEmpty);
    expect(res.first['id'], 'lib.1');
  });

  test('Get playlist tracks normalizes maps', () async {
    final res = await AppleMusicService().getPlaylistTracks('pl.1');
    expect(res, isNotEmpty);
    expect(res.first['id'], 'song.1');
    expect(res.first['title'], 'Track');
  });

  test('Play song returns true', () async {
    final ok = await AppleMusicService().playSong('song.1');
    expect(ok, isTrue);
  });
}