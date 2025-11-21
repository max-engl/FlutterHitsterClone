import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hitsterclone/services/WebApiService.dart';

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

  // Music service selection: 'spotify' or 'apple'
  String _musicService = 'spotify';
  static const String _musicServiceKey = 'music_service';

  // NEW
  String? _activeDeviceId;
  String? _availableDeviceId;
  String? _preferredDeviceId;
  bool _hasDevice = false;
  String? _currentDeviceName; // display in SetupPage

  bool get connected => _connected;
  String get token => _token;
  String get musicService => _musicService;

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

  List<String> _players = [];
  List<String> get players => _players;

  bool _hasSeenStartup = false;
  bool get hasSeenStartup => _hasSeenStartup;

  void setPreferredDeviceId(String? id) {
    _preferredDeviceId = id;
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

  void setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  void setMusicService(String service) {
    if (service != 'spotify' && service != 'apple') return;
    _musicService = service;
    notifyListeners();
    _saveMusicService();
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
    await Future.wait([
      _loadPlayers(),
      _loadStartupFlag(),
      _loadMusicService(),
    ]);
  }

  Future<void> markStartupSeen() async {
    _hasSeenStartup = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_hasSeenStartupKey, true);
    } catch (_) {}
  }

  Future<void> _saveMusicService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_musicServiceKey, _musicService);
    } catch (_) {}
  }

  Future<void> _loadMusicService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_musicServiceKey);
      if (saved == 'spotify' || saved == 'apple') {
        _musicService = saved!;
      }
    } catch (_) {}
  }
}
