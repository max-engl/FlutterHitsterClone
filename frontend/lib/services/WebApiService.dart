import 'dart:convert';
import 'dart:math';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hitsterclone/services/LogicService.dart';
import 'package:crypto/crypto.dart';

class WebApiService {
  // ===== Basics =====
  final _baseApi = 'api.spotify.com';
  final _authBase = 'accounts.spotify.com';

  // Cache/TTL nur intern (keine Device-Daten hier)
  DateTime? _lastDeviceCheckAt;
  final Duration _deviceCheckTtl = const Duration(seconds: 5);

  // ===== Http / Retry =====
  final Duration _baseBackoff = const Duration(milliseconds: 400);
  final int _maxAttempts = 3;

  Map<String, String> _authHeaders() => {
    'Authorization': 'Bearer ${Logicservice().token}',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  void setToken(String apiToken) {
    Logicservice().setToken(apiToken);
  }

  // =====================================================
  // AUTHENTICATION (PKCE)
  // =====================================================
  Future<String?> fetchSpotifyAccessToken() async {
    final clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '';
    final redirectUri =
        dotenv.env['SPOTIFY_REDIRECT_URI'] ?? 'hipsterclone://callback';
    final scopes =
        dotenv.env['SPOTIFY_SCOPES'] ??
        'user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-top-read';
    if (clientId.isEmpty) {
      print('Missing SPOTIFY_CLIENT_ID in .env');
      return null;
    }

    final verifier = _generateCodeVerifier();
    final challenge = base64UrlEncode(
      sha256.convert(utf8.encode(verifier)).bytes,
    ).replaceAll('=', '');

    final authUrl = Uri.https(_authBase, '/authorize', {
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
      Uri.parse('https://$_authBase/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
        'client_id': clientId,
        'code_verifier': verifier,
      },
    );

    if (tokenRes.statusCode != 200) {
      print('Token exchange failed: ${tokenRes.statusCode} ${tokenRes.body}');
      return null;
    }

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
  // DEVICE HANDLING (State landet im Logicservice)
  // =====================================================
  Future<bool> ensureConnected({bool force = false}) async {
    try {
      final token = Logicservice().token;
      if (token.isEmpty) {
        _markDisconnected();
        return false;
      }

      if (!force && _lastDeviceCheckAt != null) {
        final age = DateTime.now().difference(_lastDeviceCheckAt!);
        if (age < _deviceCheckTtl) return Logicservice().hasDevice;
      }

      final uri = Uri.https(_baseApi, '/v1/me/player/devices');
      final resp = await _get(uri);

      if (resp == null) {
        _markDisconnected();
        return false;
      }

      if (resp.statusCode == 200) {
        final data = _safeJson(resp.body);
        final devices = (data['devices'] as List?) ?? [];

        _lastDeviceCheckAt = DateTime.now();

        // Reset im Logicservice
        Logicservice().setHasDevice(devices.isNotEmpty);
        Logicservice().setActiveDeviceId(null);
        Logicservice().setAvailableDeviceId(null);

        // Auswahl: bevorzugtes Device > aktives > erstes verfügbares
        final preferred = Logicservice().preferredDeviceId;

        for (final d in devices.whereType<Map>()) {
          final id = d['id'] as String?;
          final active = d['is_active'] == true;
          if (id == null) continue;

          if (active) {
            Logicservice().setActiveDeviceId(id);
          }

          // erstes available merken
          if (Logicservice().availableDeviceId == null) {
            Logicservice().setAvailableDeviceId(id);
          }

          // bevorzugtes Device, falls vorhanden, priorisieren
          if (preferred != null && id == preferred) {
            Logicservice().setAvailableDeviceId(id);
          }
        }

        Logicservice().setConnected(devices.isNotEmpty);
        return devices.isNotEmpty;
      }

      if (resp.statusCode == 401) {
        print("ensureConnected 401 (token invalid/expired): ${resp.body}");
      } else if (resp.statusCode == 403) {
        print(
          "ensureConnected 403 (missing scope user-read-playback-state): ${resp.body}",
        );
      } else {
        print('ensureConnected failed: ${resp.statusCode} ${resp.body}');
      }

      _markDisconnected();
      return false;
    } catch (e) {
      print("ensureConnected error: $e");
      _markDisconnected();
      return false;
    }
  }

  void _markDisconnected() {
    Logicservice().setConnected(false);
    Logicservice().setHasDevice(false);
    Logicservice().setActiveDeviceId(null);
    // availableDeviceId/pref lassen wir unangetastet (kann als Hint nützlich sein)
    _lastDeviceCheckAt = DateTime.now();
  }

  Future<bool> transferPlaybackTo(String deviceId, {bool play = false}) async {
    try {
      final uri = Uri.https(_baseApi, '/v1/me/player');
      final body = jsonEncode({
        'device_ids': [deviceId],
        'play': play,
      });
      final resp = await _put(uri, body: body);
      if (resp != null && resp.statusCode == 204) {
        Logicservice().setPreferredDeviceId(deviceId);
        return true;
      }
      print('transferPlaybackTo failed: ${resp?.statusCode} ${resp?.body}');
      return false;
    } catch (e) {
      print('transferPlaybackTo error: $e');
      return false;
    }
  }

  Future<bool> ensureActiveDevice({bool force = false}) async {
    final hasDevice = await ensureConnected(force: force);
    if (!hasDevice) return false;

    final logic = Logicservice();
    final active = logic.activeDeviceId;
    final available = logic.availableDeviceId;
    final preferred = logic.preferredDeviceId;

    // CASE 1: already active
    if (active != null) return true;

    // CASE 2: no active, but we can activate one
    final candidate = preferred ?? available;
    if (candidate != null) {
      final ok = await transferPlaybackTo(candidate, play: true);
      if (ok) {
        await ensureConnected(force: true);
        return logic.activeDeviceId != null;
      }
    }

    // CASE 3: no usable device
    return false;
  }

  // =====================================================
  // PLAYBACK CONTROLS (robust, status-korrekt)
  // =====================================================
  Future<bool> resumePlayback() async {
    try {
      final connected = await ensureActiveDevice(force: true);
      if (!connected) return false;

      final params = <String, String>{};
      final deviceId =
          Logicservice().activeDeviceId ?? Logicservice().availableDeviceId;
      if (deviceId != null) params['device_id'] = deviceId;

      // Wenn bereits playing, muss kein Fehler geworfen werden — aber wir schicken play() idempotent
      final uri = Uri.https(_baseApi, '/v1/me/player/play', params);
      final resp = await _put(uri, body: jsonEncode({}));

      if (resp != null && resp.statusCode == 204) {
        Logicservice().setPreferredDeviceId(deviceId);
        return true;
      }

      if (resp != null && resp.statusCode == 404 && deviceId != null) {
        final transferred = await transferPlaybackTo(deviceId, play: true);
        if (transferred) {
          final retry = await _put(uri, body: jsonEncode({}));
          if (retry != null && retry.statusCode == 200) return true;
          print(
            'resumePlayback retry failed: ${retry?.statusCode} ${retry?.body}',
          );
        }
      }

      print('resumePlayback failed: ${resp?.statusCode} ${resp?.body}');
      return false;
    } catch (e) {
      print("resumePlayback error: $e");
      return false;
    }
  }

  Future<void> pausePlayback() async {
    try {
      await ensureActiveDevice(force: true);

      // Erst State checken: wenn nichts spielt → stiller Erfolg (vermeidet 403 Restriction)
      final stateRes = await _get(Uri.https(_baseApi, '/v1/me/player'));
      if (stateRes != null && stateRes.statusCode == 200) {
        final state = _safeJson(stateRes.body);
        final isPlaying = state['is_playing'] == true;
        if (!isPlaying) {
          // Nichts läuft → Pause ist ein No-Op
          return;
        }
      }

      final params = <String, String>{};
      final deviceId =
          Logicservice().activeDeviceId ?? Logicservice().availableDeviceId;
      if (deviceId != null) params['device_id'] = deviceId;

      final uri = Uri.https(_baseApi, '/v1/me/player/pause', params);
      final resp = await _put(uri);

      if (resp == null || resp.statusCode != 200) {
        print('pausePlayback failed: ${resp?.statusCode} ${resp?.body}');
      }
    } catch (e) {
      print("pausePlayback error: $e");
    }
  }

  Future<bool> skipToNext() async {
    try {
      final connected = await ensureActiveDevice(force: true);
      if (!connected) return false;

      final params = <String, String>{};
      final deviceId =
          Logicservice().activeDeviceId ?? Logicservice().availableDeviceId;
      if (deviceId != null) params['device_id'] = deviceId;

      final uri = Uri.https(_baseApi, '/v1/me/player/next', params);
      final resp = await _post(uri);

      // Spotify antwortet mit 204 bei Erfolg
      if (resp != null && resp.statusCode == 204) return true;

      print('skipToNext failed: ${resp?.statusCode} ${resp?.body}');
      return false;
    } catch (e) {
      print("skipToNext error: $e");
      return false;
    }
  }

  Future<bool> startPlaybackWithUris(List<String> uris) async {
    try {
      final connected = await ensureActiveDevice(force: true);
      if (!connected) {
        print("No active or available Spotify device");
        return false;
      }

      final deviceId =
          Logicservice().activeDeviceId ?? Logicservice().availableDeviceId;
      print(deviceId);
      final params = <String, String>{};
      if (deviceId != null) params['device_id'] = deviceId;

      final uri = Uri.https(_baseApi, '/v1/me/player/play', params);
      final body = jsonEncode({'uris': uris});
      final resp = await _put(uri, body: body);

      if (resp != null && resp.statusCode == 204) {
        Logicservice().setPreferredDeviceId(deviceId);
        return true;
      }

      if (resp != null && resp.statusCode == 404 && deviceId != null) {
        final transferred = await transferPlaybackTo(deviceId, play: true);
        if (transferred) {
          final retry = await _put(uri, body: body);
          if (retry != null && retry.statusCode == 204) return true;
          print(
            'startPlayback retry failed: ${retry?.statusCode} ${retry?.body}',
          );
        }
      }

      print('startPlaybackWithUris failed: ${resp?.statusCode} ${resp?.body}');
      return false;
    } catch (e) {
      print("startPlaybackWithUris error: $e");
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getDevices() async {
    final uri = Uri.https(_baseApi, '/v1/me/player/devices');
    final resp = await _get(uri);

    if (resp == null || resp.statusCode != 200) return [];
    final data = _safeJson(resp.body);
    final devices = (data['devices'] as List?) ?? [];
    return devices.whereType<Map<String, dynamic>>().toList();
  }

  // =====================================================
  // PLAYLIST & TRACK FETCH
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

      final response = await _get(uri);
      if (response == null) break;

      if (response.statusCode == 200) {
        final data = _safeJson(response.body);
        final items = data['items'] as List? ?? [];
        allPlaylists.addAll(
          items.whereType<Map<String, dynamic>>().map(
            (i) => Playlist.fromJson(i),
          ),
        );
        if (data['next'] == null || items.length < limit) break;
        offset += limit;
      } else if (response.statusCode == 401) {
        print('getUserPlaylists 401 (token expired).');
        break;
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
    final encodedQuery = Uri.encodeComponent(query);
    final uri = Uri.parse(
      'https://$_baseApi/v1/search?q=$encodedQuery&type=playlist&limit=20',
    );

    final response = await _get(uri);
    if (response == null) return [];

    if (response.statusCode != 200) {
      print(
        'searchPublicPlaylists error: ${response.statusCode} - ${response.body}',
      );
      return [];
    }

    final data = _safeJson(response.body);
    final items = data['playlists']?['items'] as List? ?? [];
    final results = <Map<String, dynamic>>[];

    for (final raw in items) {
      final item = (raw is Map<String, dynamic>) ? raw : null;
      if (item == null) continue;

      final images = (item['images'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .toList();

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

    return results;
  }

  Future<List<Track>> getArtistTrackUris(
    String artistName, {
    void Function(int fetchedAlbums)? onAlbumProgress,
  }) async {
    try {
      final encodedName = Uri.encodeComponent(artistName);
      final searchUrl = Uri.parse(
        'https://$_baseApi/v1/search?q=$encodedName&type=artist&limit=1',
      );
      final searchRes = await _get(searchUrl);

      if (searchRes == null || searchRes.statusCode != 200) {
        print('Search error: ${searchRes?.statusCode} - ${searchRes?.body}');
        return [];
      }

      final searchData = _safeJson(searchRes.body);
      final items = searchData['artists']?['items'] as List? ?? [];
      if (items.isEmpty) {
        print('Artist not found.');
        return [];
      }

      final artistId = (items[0] as Map)['id'];
      return getArtistTrackUrisById(
        '$artistId',
        onAlbumProgress: onAlbumProgress,
      );
    } catch (e) {
      print('getArtistTrackUris error: $e');
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
      final albumsRes = await _get(Uri.parse(nextUrl));
      if (albumsRes == null || albumsRes.statusCode != 200) {
        print('Albums error: ${albumsRes?.statusCode} - ${albumsRes?.body}');
        break;
      }

      final albumsData = _safeJson(albumsRes.body);
      final albums = albumsData['items'] as List? ?? [];

      for (final a in albums) {
        final albumId = (a as Map)['id'];
        final tracksUrl = Uri.parse(
          'https://$_baseApi/v1/albums/$albumId/tracks?limit=50',
        );
        final tracksRes = await _get(tracksUrl);

        if (tracksRes == null || tracksRes.statusCode != 200) {
          print('Tracks error: ${tracksRes?.statusCode} - ${tracksRes?.body}');
          continue;
        }

        final tracksData = _safeJson(tracksRes.body);
        final albumTracks = tracksData['items'] as List? ?? [];

        final albumImages =
            ((a as Map<String, dynamic>)['images'] as List? ?? [])
                .whereType<Map<String, dynamic>>()
                .toList();
        final albumImageUrl = albumImages.isNotEmpty
            ? (albumImages.first['url'] as String?)
            : null;
        final albumName = (a as Map<String, dynamic>)['name'] as String?;

        for (final t in albumTracks) {
          final track = (t as Map<String, dynamic>);
          final uri = track['uri'];
          if (uri is String && !seenUris.contains(uri)) {
            seenUris.add(uri);
            final artistsList = ((track['artists'] as List? ?? []).map(
              (aa) => (aa is Map<String, dynamic>)
                  ? (aa['name'] as String? ?? 'Unknown')
                  : 'Unknown',
            )).toList();

            tracks.add(
              Track(
                id: track['id'] as String? ?? '',
                name: track['name'] as String? ?? 'UNKNOWN',
                artists: artistsList,
                albumName: albumName,
                albumImageUrl: albumImageUrl,
                uri: uri,
                durationMs: (track['duration_ms'] as int? ?? 0),
              ),
            );
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

  Future<List<Artist>> searchArtist(String artistName) async {
    try {
      final query = Uri.encodeComponent(artistName);
      final uri = Uri.parse(
        'https://$_baseApi/v1/search?q=$query&type=artist&limit=10',
      );

      final response = await _get(uri);
      if (response == null) return [];

      if (response.statusCode == 200) {
        final data = _safeJson(response.body);
        final items = (data['artists']?['items'] as List?) ?? [];
        return items
            .whereType<Map<String, dynamic>>()
            .map((i) => Artist.fromJson(i))
            .toList();
      } else if (response.statusCode == 401) {
        print('searchArtist 401 (token expired).');
        return [];
      } else {
        print('searchArtist failed: ${response.statusCode} ${response.body}');
        return [];
      }
    } catch (e) {
      print('searchArtist error: $e');
      return [];
    }
  }

  Future<List<Track>> getPlaylistTracks(
    String playlistId,
    bool isPublic,
  ) async {
    final List<Track> allTracks = [];
    int offset = 0;
    const int limit = 100;

    while (true) {
      final uri = Uri.https(_baseApi, '/v1/playlists/$playlistId/tracks', {
        'limit': '$limit',
        'offset': '$offset',
      });

      final response = await _get(uri);
      if (response == null) break;

      if (response.statusCode == 200) {
        final data = _safeJson(response.body);
        final items = data['items'] as List? ?? [];

        for (final item in items) {
          final trackJson = (item as Map)['track'] as Map<String, dynamic>?;
          if (trackJson != null) allTracks.add(Track.fromJson(trackJson));
        }

        if (data['next'] == null || items.length < limit) break;
        offset += limit;
      } else {
        print(
          'getPlaylistTracks failed: ${response.statusCode} ${response.body}',
        );
        break;
      }
    }
    Logicservice().setPlaylistType(isPublic);
    return allTracks;
  }

  // =====================================================
  // HTTP Helpers (Retry, 429, 5xx)
  // =====================================================
  Future<http.Response?> _get(Uri uri) =>
      _withRetry(() => http.get(uri, headers: _authHeaders()));
  Future<http.Response?> _put(Uri uri, {String? body}) =>
      _withRetry(() => http.put(uri, headers: _authHeaders(), body: body));
  Future<http.Response?> _post(Uri uri, {String? body}) =>
      _withRetry(() => http.post(uri, headers: _authHeaders(), body: body));

  Future<http.Response?> _withRetry(
    Future<http.Response> Function() send,
  ) async {
    http.Response? last;
    for (int attempt = 1; attempt <= _maxAttempts; attempt++) {
      try {
        final resp = await send();
        // Erfolg oder Clientfehler (außer 429) → kein weiterer Retry
        if (resp.statusCode < 500 && resp.statusCode != 429) return resp;

        // 429 → respect Retry-After
        if (resp.statusCode == 429) {
          final retrySec = int.tryParse(resp.headers['retry-after'] ?? '') ?? 1;
          await Future.delayed(Duration(seconds: retrySec));
          last = resp;
          continue;
        }

        // 5xx → exponential backoff
        if (resp.statusCode >= 500) {
          await Future.delayed(_expBackoff(attempt));
          last = resp;
          continue;
        }

        return resp;
      } catch (e) {
        if (attempt == _maxAttempts) {
          print('HTTP fatal after $attempt attempts: $e');
          return last;
        }
        await Future.delayed(_expBackoff(attempt));
      }
    }
    return last;
  }

  Duration _expBackoff(int attempt) {
    final mult = pow(2, attempt - 1).toInt();
    return _baseBackoff * mult;
  }

  Map<String, dynamic> _safeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

// =====================================================
// DATA CLASSES (unverändert inhaltlich, robustere Typ-Casts)
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
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'UNKNOWN',
      imageUrl: images.isNotEmpty ? (images.first['url'] as String?) : null,
    );
  }
}
