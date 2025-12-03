import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:http/http.dart' as http;

class Logicservice extends ChangeNotifier {
  static final Logicservice _instance = Logicservice._internal();
  factory Logicservice() => _instance;
  late final Future<void> initFuture;
  Logicservice._internal() {
    initFuture = _initialize();
  }

  static const String _playersKey = 'players';
  static const String _hasSeenStartupKey = 'has_seen_startup';

  List<Track> _tracks = [];
  List<Track> _trackYetToPlay = [];
  String _playlistId = '';
  Playlist? _playlist;
  int _rounds = 10;

  bool _connected = false;
  String _token = '';

  // NEW
  String? _activeDeviceId;
  String? _availableDeviceId;
  String? _preferredDeviceId;
  bool _hasDevice = false;
  String? _currentDeviceName; // display in SetupPage

  // NEW
  bool? _playListType;

  bool get connected => _connected;
  String get token => _token;

  List<Track> get tracks => _tracks;
  List<Track> get trackYetToPlay => _trackYetToPlay;
  String get playlistId => _playlistId;
  Playlist? get playlist => _playlist;
  int get rounds => _rounds;
  bool get hasDevice => _hasDevice;

  String? get activeDeviceId => _activeDeviceId;
  String? get availableDeviceId => _availableDeviceId;
  String? get preferredDeviceId => _preferredDeviceId;
  String? get currentDeviceName => _currentDeviceName;

  // NEW
  bool? get playListType => _playListType;

  List<String> _players = [];
  List<String> get players => _players;

  bool _hasSeenStartup = false;
  bool get hasSeenStartup => _hasSeenStartup;

  void setPreferredDeviceId(String? id) {
    _preferredDeviceId = id;
    notifyListeners();
  }

  void setPlaylistType(bool type) {
    _playListType = type;
    notifyListeners();
  }

  void setActiveDeviceId(String? id) {
    _activeDeviceId = id;
    notifyListeners();
  }

  void setAvailableDeviceId(String? id) {
    _availableDeviceId = id;
    notifyListeners();
  }

  void setHasDevice(bool value) {
    _hasDevice = value;
    notifyListeners();
  }

  void setCurrentDeviceName(String? name) {
    _currentDeviceName = name;
    notifyListeners();
  }

  Future<void> uploadPlayList() async {
    if (_playListType == false) return;
    if (_playlist == null) return;
    final baseUrl = dotenv.env['BACKEND_URL'];
    final uri = Uri.parse('$baseUrl/playlist');
    final body = {
      'playListID': _playlist!.id,
      'name': _playlist!.name,
      'description': _playlist!.description,
      'imageUrl': _playlist!.imageUrl,
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print("success");
      } else {
        print('Upload failed: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Upload error: $e');
    }

    print(_playlist!.imageUrl);
  }

  void setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  void setConnected(bool newConnected) {
    _connected = newConnected;
    notifyListeners();
  }

  void setPlaylist(Playlist? playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  void setPlaylistId(String id) {
    _playlistId = id;
    notifyListeners();
  }

  void setTracks(List<Track> newTracks) {
    _tracks = newTracks;
    _trackYetToPlay = newTracks.toList();
    notifyListeners();
  }

  void resetTracksToPlay() {
    _trackYetToPlay = _tracks.toList();
    notifyListeners();
  }

  void removeTrackYetToplay(Track track) {
    _trackYetToPlay.remove(track);
    notifyListeners();
  }

  void setRounds(int r) {
    _rounds = r;
    notifyListeners();
  }

  void setPlayers(List<String> newPlayers) {
    _players = newPlayers;
    notifyListeners();
    _savePlayers();
  }

  Future<void> _savePlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_playersKey, _players);
    } catch (_) {}
  }

  Future<void> _loadPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_playersKey);
      if (saved != null) {
        _players = saved;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _loadStartupFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasSeenStartup = prefs.getBool(_hasSeenStartupKey) ?? false;
    } catch (_) {}
  }

  Future<void> _initialize() async {
    await Future.wait([_loadPlayers(), _loadStartupFlag()]);
  }

  Future<void> markStartupSeen() async {
    _hasSeenStartup = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenStartupKey, true);
    } catch (_) {}
  }
}
