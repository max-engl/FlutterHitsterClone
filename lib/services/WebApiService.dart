import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_sdk/spotify_sdk.dart';
import 'package:hitsterclone/services/LogicService.dart';

class WebApiService {
  final _baseApi = 'api.spotify.com';
  final _authBase = 'accounts.spotify.com';

  // =====================================================
  // AUTHENTICATION (SDK token, returned for Web API usage)
  // =====================================================
  Future<String?> fetchSpotifyAccessToken() async {
    const clientId = '28cb945996d04097b8b516575cc6322a';
    const redirectUri = 'hipsterclone://callback';
    const scopes =
        'user-read-playback-state,user-modify-playback-state,user-read-currently-playing,playlist-read-private,playlist-read-collaborative,user-top-read';

    try {
      final token = await SpotifySdk.getAuthenticationToken(
        clientId: clientId,
        redirectUrl: redirectUri,
        scope: scopes,
      );

      Logicservice().setToken(token);
      return token;
    } catch (e) {
      print("fetchSpotifyAccessToken error: $e");
      return null;
    }
  }

  // =====================================================
  // COMPATIBILITY NO-OPS (ORIGINAL METHODS KEPT)
  // =====================================================
  Future<bool> ensureConnected({bool force = false}) async {
    return true; // no-op, SDK does not need this
  }

  Future<bool> ensureActiveDevice({bool force = false}) async {
    return true; // no-op
  }

  // =====================================================
  // PLAYBACK (SDK)
  // =====================================================
  Future<bool> resumePlayback() async {
    try {
      await SpotifySdk.resume();
      return true;
    } catch (e) {
      print("resumePlayback error: $e");
      return false;
    }
  }

  Future<void> pausePlayback() async {
    try {
      await SpotifySdk.pause();
    } catch (e) {
      print("pausePlayback error: $e");
    }
  }

  Future<bool> skipToNext() async {
    try {
      await SpotifySdk.skipNext();
      return true;
    } catch (e) {
      print("skipToNext error: $e");
      return false;
    }
  }

  Future<bool> startPlaybackWithUris(List<String> uris) async {
    try {
      if (uris.isEmpty) return false;

      final deviceId = Logicservice().preferredDeviceId;

      await SpotifySdk.play(spotifyUri: uris.first);
      return true;
    } catch (e) {
      print("startPlaybackWithUris error: $e");
      return false;
    }
  }

  // =====================================================
  // SEARCH + PLAYLIST (HTTP remains the same)
  // =====================================================
  Map<String, String> _authHeaders() => {
    'Authorization': 'Bearer ${Logicservice().token}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<List<Map<String, dynamic>>> searchPublicPlaylists(String query) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://$_baseApi/v1/search?q=$encoded&type=playlist&limit=20',
    );

    final resp = await http.get(uri, headers: _authHeaders());
    if (resp.statusCode != 200) return [];

    final data = jsonDecode(resp.body);
    final items = data['playlists']?['items'] as List? ?? [];

    return items.map<Map<String, dynamic>>((item) {
      final images = item['images'] as List? ?? [];
      return {
        'name': item['name'] ?? 'Untitled',
        'id': item['id'],
        'uri': item['uri'],
        'tracks': (item['tracks']?['total']) ?? 0,
        'image': images.isNotEmpty ? images.first['url'] : null,
      };
    }).toList();
  }

  // =====================================================
  // ARTIST + PLAYLIST + TRACK FETCH (UNTOUCHED LOGIC)
  // =====================================================
  Future<List<Playlist>> getUserPlaylists() async {
    final List<Playlist> allPlaylists = [];
    int offset = 0;
    const int limit = 50;

    while (true) {
      final uri = Uri.https(_baseApi, '/v1/me/playlists', {
        'limit': '$limit',
        'offset': '$offset',
      });

      final response = await http.get(uri, headers: _authHeaders());
      if (response.statusCode != 200) break;

      final data = jsonDecode(response.body);
      final items = data['items'] as List? ?? [];

      allPlaylists.addAll(
        items.whereType<Map<String, dynamic>>().map(
          (i) => Playlist.fromJson(i),
        ),
      );

      if (data['next'] == null || items.length < limit) break;
      offset += limit;
    }
    return allPlaylists;
  }

  Future<List<Artist>> searchArtist(String artistName) async {
    try {
      final query = Uri.encodeComponent(artistName);
      final uri = Uri.parse(
        'https://$_baseApi/v1/search?q=$query&type=artist&limit=10',
      );

      final resp = await http.get(uri, headers: _authHeaders());
      if (resp.statusCode != 200) return [];

      final data = jsonDecode(resp.body);
      final items = data['artists']?['items'] as List? ?? [];
      return items
          .whereType<Map<String, dynamic>>()
          .map((i) => Artist.fromJson(i))
          .toList();
    } catch (e) {
      print("searchArtist error: $e");
      return [];
    }
  }

  Future<List<Track>> getArtistTrackUris(
    String artistName, {
    void Function(int fetchedAlbums)? onAlbumProgress,
  }) async {
    try {
      final encoded = Uri.encodeComponent(artistName);
      final searchUrl = Uri.parse(
        'https://$_baseApi/v1/search?q=$encoded&type=artist&limit=1',
      );
      final searchRes = await http.get(searchUrl, headers: _authHeaders());
      if (searchRes.statusCode != 200) return [];

      final searchData = jsonDecode(searchRes.body);
      final items = searchData['artists']?['items'] as List? ?? [];
      if (items.isEmpty) return [];

      final artistId = (items[0] as Map)['id'];
      return getArtistTrackUrisById(artistId, onAlbumProgress: onAlbumProgress);
    } catch (e) {
      print("getArtistTrackUris error: $e");
      return [];
    }
  }

  Future<List<Track>> getArtistTrackUrisById(
    String artistId, {
    void Function(int fetchedAlbums)? onAlbumProgress,
  }) async {
    final List<Track> tracks = [];
    final Set<String> seenUris = {};
    String? nextUrl =
        'https://$_baseApi/v1/artists/$artistId/albums?include_groups=album,single&limit=50';
    int processedAlbums = 0;

    while (nextUrl != null) {
      final albumsRes = await http.get(
        Uri.parse(nextUrl),
        headers: _authHeaders(),
      );
      if (albumsRes.statusCode != 200) break;

      final albumsData = jsonDecode(albumsRes.body);
      final albums = albumsData['items'] as List? ?? [];

      for (final a in albums) {
        final albumId = (a as Map)['id'];
        final tracksUrl = Uri.parse(
          'https://$_baseApi/v1/albums/$albumId/tracks?limit=50',
        );
        final tracksRes = await http.get(tracksUrl, headers: _authHeaders());

        if (tracksRes.statusCode != 200) continue;

        final tracksData = jsonDecode(tracksRes.body);
        final albumTracks = tracksData['items'] as List? ?? [];

        for (final t in albumTracks) {
          final track = (t as Map<String, dynamic>);
          final uri = track['uri'];
          if (uri is String && !seenUris.contains(uri)) {
            seenUris.add(uri);
            tracks.add(Track.fromJson(track));
          }
        }

        if (onAlbumProgress != null) {
          processedAlbums++;
          onAlbumProgress(processedAlbums);
        }
      }

      nextUrl = albumsData['next'];
    }
    return tracks;
  }

  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    final List<Track> allTracks = [];
    int offset = 0;
    const int limit = 100;

    while (true) {
      final uri = Uri.https(_baseApi, '/v1/playlists/$playlistId/tracks', {
        'limit': '$limit',
        'offset': '$offset',
      });

      final resp = await http.get(uri, headers: _authHeaders());
      if (resp.statusCode != 200) break;

      final data = jsonDecode(resp.body);
      final items = data['items'] as List? ?? [];

      for (final item in items) {
        final trackJson = (item as Map)['track'] as Map<String, dynamic>?;
        if (trackJson != null) allTracks.add(Track.fromJson(trackJson));
      }

      if (data['next'] == null || items.length < limit) break;
      offset += limit;
    }
    return allTracks;
  }
}

// =====================================================
// DATA CLASSES
// =====================================================
class Playlist {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  Playlist({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List? ?? [];
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'UNNAMED',
      description: json['description'] as String?,
      imageUrl: images.isNotEmpty ? (images.first['url'] as String?) : null,
    );
  }
}

class Track {
  final String id;
  final String name;
  final List<String> artists;
  final String? albumName;
  final String? albumImageUrl;
  final String uri;
  final int durationMs;

  Track({
    required this.id,
    required this.name,
    required this.artists,
    this.albumName,
    this.albumImageUrl,
    required this.uri,
    required this.durationMs,
  });

  factory Track.fromJson(Map<String, dynamic> json) {
    final artistsList = (json['artists'] as List? ?? [])
        .map(
          (a) => (a is Map<String, dynamic>)
              ? (a['name'] as String? ?? 'Unknown')
              : 'Unknown',
        )
        .toList();

    final album = json['album'] as Map<String, dynamic>?;
    final images = (album?['images'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .toList();

    return Track(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'UNKNOWN',
      artists: artistsList,
      albumName: album?['name'] as String?,
      albumImageUrl: images.isNotEmpty ? images.first['url'] as String? : null,
      uri: json['uri'] as String? ?? '',
      durationMs: json['duration_ms'] as int? ?? 0,
    );
  }
}

class Artist {
  final String id;
  final String name;
  final String? imageUrl;

  Artist({required this.id, required this.name, this.imageUrl});

  factory Artist.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List? ?? [];
    return Artist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'UNKNOWN',
      imageUrl: images.isNotEmpty ? (images.first['url'] as String?) : null,
    );
  }
}
