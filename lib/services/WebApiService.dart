import 'dart:convert';
import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:hitsterclone/services/LogicService.dart';
import 'package:crypto/crypto.dart';

class WebApiService {
  DateTime? _lastDeviceCheckAt;
  bool _lastHasDevice = false;
  final Duration _deviceCheckTtl = const Duration(seconds: 5);
  String? _lastActiveDeviceId;
  String? _lastAvailableDeviceId;

  Map<String, String> _authHeaders() => {
    'Authorization': 'Bearer ${Logicservice().token}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setToken(String apiToken) {
    Logicservice().setToken(apiToken);
  }

  // =====================================================
  // AUTHENTICATION  (nur Scopes erweitert)
  // =====================================================
  Future<String?> fetchSpotifyAccessToken() async {
    const clientId = '28cb945996d04097b8b516575cc6322a';
    const redirectUri = 'hipsterclone://callback';
    // WICHTIG: playback-read Scope hinzufügen, sonst /devices unzuverlässig
    const scopes =
        'user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-top-read';
    final verifier = _generateCodeVerifier();
    final challenge = base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '');

    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'code',
      'client_id': clientId,
      'scope': scopes,
      'redirect_uri': redirectUri,
      'code_challenge_method': 'S256',
      'code_challenge': challenge,
    });

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: 'hipsterclone',
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) return null;

    final tokenRes = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': verifier,
      },
    );

    final tokenData = jsonDecode(tokenRes.body);
    return tokenData['access_token'];
  }

  String _generateCodeVerifier() {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final rand = Random.secure();
    return List.generate(
      64,
      (_) => charset[rand.nextInt(charset.length)],
    ).join();
  }

  // =====================================================
  // DEVICE HANDLING
  // =====================================================
  Future<bool> ensureConnected({bool force = false}) async {
    try {
      final token = Logicservice().token;
      if (token.isEmpty) {
        Logicservice().setConnected(false);
        return false;
      }

      if (!force && _lastDeviceCheckAt != null) {
        final age = DateTime.now().difference(_lastDeviceCheckAt!);
        if (age < _deviceCheckTtl) return _lastHasDevice;
      }

      final uri = Uri.https('api.spotify.com', '/v1/me/player/devices');
      final resp = await http.get(uri, headers: _authHeaders());

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final devices = (data['devices'] as List?) ?? [];
        final hasDevice = devices.isNotEmpty;

        _lastDeviceCheckAt = DateTime.now();
        _lastHasDevice = hasDevice;
        _lastActiveDeviceId = null;
        _lastAvailableDeviceId = null;

        if (hasDevice) {
          for (final d in devices) {
            final id = d['id'] as String?;
            final active = d['is_active'] == true;
            if (active && id != null) {
              _lastActiveDeviceId = id;
            } else if (_lastAvailableDeviceId == null && id != null) {
              _lastAvailableDeviceId = id;
            }
          }
        }

        Logicservice().setConnected(hasDevice);
        return hasDevice;
      }

      if (resp.statusCode == 401) {
        print("Token expired/invalid (401): ${resp.body}");
      } else if (resp.statusCode == 403) {
        print("Missing scope user-read-playback-state (403): ${resp.body}");
      } else {
        print('Device fetch failed: ${resp.statusCode} ${resp.body}');
      }

      Logicservice().setConnected(false);
      _lastHasDevice = false;
      _lastDeviceCheckAt = DateTime.now();
      return false;
    } catch (e) {
      print("ensureConnected error: $e");
      Logicservice().setConnected(false);
      _lastHasDevice = false;
      _lastDeviceCheckAt = DateTime.now();
      return false;
    }
  }

  Future<bool> transferPlaybackTo(String deviceId, {bool play = false}) async {
    try {
      final uri = Uri.https('api.spotify.com', '/v1/me/player');
      final body = jsonEncode({
        'device_ids': [deviceId],
        'play': play,
      });
      final resp = await http.put(uri, headers: _authHeaders(), body: body);
      if (resp.statusCode == 204) return true;
      print('transferPlaybackTo failed: ${resp.statusCode} ${resp.body}');
      return false;
    } catch (e) {
      print('transferPlaybackTo error: $e');
      return false;
    }
  }

  Future<bool> ensureActiveDevice({bool force = false}) async {
    final hasDevice = await ensureConnected(force: force);
    if (!hasDevice) return false;

    if (_lastActiveDeviceId != null) return true;

    if (_lastAvailableDeviceId != null) {
      // Wichtig: play:true, damit das Gerät „aktiv“ wird
      final ok = await transferPlaybackTo(_lastAvailableDeviceId!, play: true);
      if (ok) {
        await ensureConnected(force: true);
        return _lastActiveDeviceId != null;
      }
    }
    return false;
  }

  // =====================================================
  // PLAYBACK CONTROLS
  // =====================================================
  Future<bool> resumePlayback() async {
    try {
      // final connected = await ensureActiveDevice();
      //  if (!connected) return false;

      // device_id anhängen, falls bekannt
      final params = <String, String>{};
      if (_lastActiveDeviceId != null) {
        params['device_id'] = _lastActiveDeviceId!;
      }

      final uri = Uri.https('api.spotify.com', '/v1/me/player/play', params);
      final resp = await http.put(uri, headers: _authHeaders());
      if (resp.statusCode == 204) return true;

      print('resumePlayback failed: ${resp.statusCode} ${resp.body}');
      return false;
    } catch (e) {
      print("resumePlayback error: $e");
      return false;
    }
  }

  Future<void> pausePlayback() async {
    try {
      // final connected = await ensureActiveDevice();
      // if (!connected) return;
      print("TRYING TO PAUSE NOW");
      final params = <String, String>{};
      if (_lastActiveDeviceId != null) {
        params['device_id'] = _lastActiveDeviceId!;
      }

      final uri = Uri.https('api.spotify.com', '/v1/me/player/pause', params);
      final resp = await http.put(uri, headers: _authHeaders());
      if (resp.statusCode != 200) {
        print('pausePlayback failed: ${resp.statusCode} ${resp.body}');
      }
    } catch (e) {
      print("pausePlayback error: $e");
    }
  }

  Future<bool> skipToNext() async {
    try {
      final connected = await ensureActiveDevice();
      if (!connected) return false;

      final params = <String, String>{};
      if (_lastActiveDeviceId != null) {
        params['device_id'] = _lastActiveDeviceId!;
      }

      final uri = Uri.https('api.spotify.com', '/v1/me/player/next', params);
      final resp = await http.post(uri, headers: _authHeaders());
      if (resp.statusCode == 200) return true;
      print('skipToNext failed: ${resp.statusCode} ${resp.body}');
      return false;
    } catch (e) {
      print("skipToNext error: $e");
      return false;
    }
  }

  Future<bool> startPlaybackWithUris(List<String> uris) async {
    try {
      final connected = await ensureActiveDevice();
      if (!connected) {
        print("No active Spotify device.");
        return false;
      }

      // device_id gezielt setzen, um 404/„No active device“ zu vermeiden
      final params = <String, String>{};
      final deviceId = _lastActiveDeviceId ?? _lastAvailableDeviceId;
      // if (deviceId != null) params['device_id'] = deviceId;

      final uri = Uri.https('api.spotify.com', '/v1/me/player/play', params);
      final body = jsonEncode({'uris': uris});
      final resp = await http.put(uri, headers: _authHeaders(), body: body);
      if (resp.statusCode == 204) return true;

      // Fallback: falls 404 kommt, noch einmal mit Transfer+Play versuchen
      if (resp.statusCode == 404 && deviceId != null) {
        final transferred = await transferPlaybackTo(deviceId, play: true);
        if (transferred) {
          final retry = await http.put(
            uri,
            headers: _authHeaders(),
            body: body,
          );
          if (retry.statusCode == 204) return true;
          print(
            'startPlayback retry failed: ${retry.statusCode} ${retry.body}',
          );
        }
      }

      print('startPlaybackWithUris failed: ${resp.statusCode} ${resp.body}');
      return false;
    } catch (e) {
      print("startPlaybackWithUris error: $e");
      return false;
    }
  }

  // =====================================================
  // PLAYLIST & TRACK FETCH
  // =====================================================
  Future<List<Playlist>> getUserPlaylists() async {
    final List<Playlist> allPlaylists = [];
    int offset = 0;
    const int limit = 50;

    while (true) {
      final uri = Uri.https('api.spotify.com', '/v1/me/playlists', {
        'limit': '$limit',
        'offset': '$offset',
      });

      final response = await http.get(uri, headers: _authHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List? ?? [];
        allPlaylists.addAll(items.map((i) => Playlist.fromJson(i)));
        if (data['next'] == null || items.length < limit) break;
        offset += limit;
      } else if (response.statusCode == 401) {
        print('Unauthorized (token expired).');
        break;
      } else if (response.statusCode == 429) {
        final retry = int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
        await Future.delayed(Duration(seconds: retry));
      } else {
        print(
          'getUserPlaylists failed: ${response.statusCode} ${response.body}',
        );
        break;
      }
    }

    return allPlaylists;
  }

  Future<List<Map<String, dynamic>>> searchPublicPlaylists(String query) async {
    final headers = _authHeaders();
    final encodedQuery = Uri.encodeComponent(query);

    final url =
        'https://api.spotify.com/v1/search?q=$encodedQuery&type=playlist&limit=20';
    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode != 200) {
      print('Error: ${response.statusCode} - ${response.body}');
      return [];
    }

    final data = jsonDecode(response.body);
    final items = data['playlists']?['items'] as List? ?? [];

    List<Map<String, dynamic>> results = [];
    if (results.length > 0) {}
    for (final item in items) {
      if (item is! Map<String, dynamic>)
        continue; // skip nulls or unexpected types

      final images = (item['images'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();
      final imageUrl = images.isNotEmpty
          ? (images.first['url'] as String?)
          : null;

      results.add({
        'name': item['name'] as String? ?? 'Untitled Playlist',
        'id': item['id'] as String? ?? '',
        'uri': item['uri'] as String? ?? '',
        'owner':
            (item['owner'] as Map<String, dynamic>?)?['display_name']
                as String?,
        'tracks': (item['tracks'] as Map<String, dynamic>?)?['total'] as int?,
        'images': images,
      });
    }

    print('Found ${results.length} playlists for "$query".');
    return results;
  }

  Future<List<Track>> getArtistTrackUris(
    String artistName, {
    void Function(int fetchedAlbums)? onAlbumProgress,
  }) async {
    final headers = _authHeaders();
    final encodedName = Uri.encodeComponent(artistName);

    // 1. Search for artist ID
    final searchUrl =
        'https://api.spotify.com/v1/search?q=$encodedName&type=artist&limit=1';
    final searchRes = await http.get(Uri.parse(searchUrl), headers: headers);

    if (searchRes.statusCode != 200) {
      print('Search error: ${searchRes.statusCode} - ${searchRes.body}');
      return [];
    }

    final searchData = jsonDecode(searchRes.body);
    final items = searchData['artists']?['items'] ?? [];

    if (items.isEmpty) {
      print('Artist not found.');
      return [];
    }

    final artistId = items[0]['id'];
    print('Found artist: ${items[0]['name']} (ID: $artistId)');

    // 2. Get all albums
    List<Track> tracks = [];
    Set<String> seenUris = {};
    String? albumsUrl =
        'https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album,single&limit=50';
    int processedAlbums = 0;

    while (albumsUrl != null) {
      final albumsRes = await http.get(Uri.parse(albumsUrl), headers: headers);

      if (albumsRes.statusCode != 200) {
        print('Albums error: ${albumsRes.statusCode} - ${albumsRes.body}');
        break;
      }

      final albumsData = jsonDecode(albumsRes.body);
      final albums = albumsData['items'] ?? [];

      for (var album in albums) {
        final albumId = album['id'];
        final albumName = album['name'];
        // print('Fetching tracks from album: $albumName');

        // 3. Get tracks for each album
        final tracksUrl =
            'https://api.spotify.com/v1/albums/$albumId/tracks?limit=50';
        final tracksRes = await http.get(
          Uri.parse(tracksUrl),
          headers: headers,
        );

        if (tracksRes.statusCode != 200) {
          print('Tracks error: ${tracksRes.statusCode} - ${tracksRes.body}');
          continue;
        }

        final tracksData = jsonDecode(tracksRes.body);
        final albumTracks = tracksData['items'] ?? [];

        for (var track in albumTracks) {
          final uri = track['uri'];
          if (!seenUris.contains(uri)) {
            seenUris.add(uri);
            // Convert to Track model
            try {
              tracks.add(Track.fromJson(track));
            } catch (_) {
              // Fallback minimal mapping if structure differs
              tracks.add(
                Track(
                  id: track['id'] as String? ?? '',
                  name: track['name'] as String? ?? 'UNKNOWN',
                  artists: (((track['artists'] as List?) ?? []).map(
                    (a) => (a is Map<String, dynamic>)
                        ? (a['name'] as String? ?? 'Unknown')
                        : 'Unknown',
                  )).toList(),
                  albumName: null,
                  albumImageUrl: null,
                  uri: (uri is String) ? uri : (track['uri'] as String? ?? ''),
                  durationMs: (track['duration_ms'] as int? ?? 0),
                ),
              );
            }
          }
        }

        // Progress callback after each album processed
        if (onAlbumProgress != null) {
          processedAlbums++;
          onAlbumProgress(processedAlbums);
        }
      }

      albumsUrl = albumsData['next']; // Pagination
    }

    // print('Total unique tracks found: ${tracks.length}');
    return tracks;
  }

  // Variant that uses artist ID directly (avoids name-based search mismatches)
  Future<List<Track>> getArtistTrackUrisById(
    String artistId, {
    void Function(int fetchedAlbums)? onAlbumProgress,
  }) async {
    final headers = _authHeaders();

    // 1. Get all albums for provided artist ID
    List<Track> tracks = [];
    Set<String> seenUris = {};
    String? albumsUrl =
        'https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album,single&limit=50';
    int processedAlbums = 0;

    while (albumsUrl != null) {
      final albumsRes = await http.get(Uri.parse(albumsUrl), headers: headers);

      if (albumsRes.statusCode != 200) {
        print('Albums error: ${albumsRes.statusCode} - ${albumsRes.body}');
        break;
      }

      final albumsData = jsonDecode(albumsRes.body);
      final albums = albumsData['items'] ?? [];

      for (var album in albums) {
        final albumId = album['id'];

        // 2. Get tracks for each album
        final tracksUrl =
            'https://api.spotify.com/v1/albums/$albumId/tracks?limit=50';
        final tracksRes = await http.get(
          Uri.parse(tracksUrl),
          headers: headers,
        );

        if (tracksRes.statusCode != 200) {
          print('Tracks error: ${tracksRes.statusCode} - ${tracksRes.body}');
          continue;
        }

        final tracksData = jsonDecode(tracksRes.body);
        final albumTracks = tracksData['items'] ?? [];

        for (var track in albumTracks) {
          final uri = track['uri'];
          if (!seenUris.contains(uri)) {
            seenUris.add(uri);
            try {
              tracks.add(Track.fromJson(track));
            } catch (_) {
              tracks.add(
                Track(
                  id: track['id'] as String? ?? '',
                  name: track['name'] as String? ?? 'UNKNOWN',
                  artists: (((track['artists'] as List?) ?? []).map(
                    (a) => (a is Map<String, dynamic>)
                        ? (a['name'] as String? ?? 'Unknown')
                        : 'Unknown',
                  )).toList(),
                  albumName: null,
                  albumImageUrl: null,
                  uri: (uri is String) ? uri : (track['uri'] as String? ?? ''),
                  durationMs: (track['duration_ms'] as int? ?? 0),
                ),
              );
            }
          }
        }

        if (onAlbumProgress != null) {
          processedAlbums++;
          onAlbumProgress(processedAlbums);
        }
      }

      albumsUrl = albumsData['next']; // Pagination
    }

    return tracks;
  }

  Future<List<Artist>> searchArtist(String artistName) async {
    try {
      final query = Uri.encodeComponent(artistName);
      final uri = Uri.parse(
        'https://api.spotify.com/v1/search?q=$query&type=artist&limit=10',
      );

      final response = await http.get(uri, headers: _authHeaders());
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = (data['artists']?['items'] as List?) ?? [];
        return items.map((i) => Artist.fromJson(i)).toList();
      } else if (response.statusCode == 401) {
        print('Unauthorized (token expired).');
        return [];
      } else if (response.statusCode == 429) {
        final retry = int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
        await Future.delayed(Duration(seconds: retry));
        return await searchArtist(artistName);
      } else {
        print('searchArtist failed: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('searchArtist error: $e');
      return [];
    }
  }

  Future<List<Track>> getPlaylistTracks(String playlistId) async {
    final List<Track> allTracks = [];
    int offset = 0;
    const int limit = 100;

    while (true) {
      final uri = Uri.https(
        'api.spotify.com',
        '/v1/playlists/$playlistId/tracks',
        {'limit': '$limit', 'offset': '$offset'},
      );

      final response = await http.get(uri, headers: _authHeaders());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List? ?? [];

        for (final item in items) {
          final trackJson = item['track'] as Map<String, dynamic>?;
          if (trackJson != null) allTracks.add(Track.fromJson(trackJson));
        }

        if (data['next'] == null || items.length < limit) break;
        offset += limit;
      } else if (response.statusCode == 429) {
        final retry = int.tryParse(response.headers['retry-after'] ?? '1') ?? 1;
        await Future.delayed(Duration(seconds: retry));
      } else {
        print(
          'getPlaylistTracks failed: ${response.statusCode} ${response.body}',
        );
        break;
      }
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: images.isNotEmpty ? images.first['url'] : null,
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
      albumImageUrl: images.isNotEmpty
          ? (images.first['url'] as String?)
          : null,
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
      id: json['id'] ?? '',
      name: json['name'] ?? 'UNKNOWN',
      imageUrl: images.isNotEmpty ? (images.first['url'] as String?) : null,
    );
  }
}
