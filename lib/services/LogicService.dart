import 'package:flutter/material.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logicservice extends ChangeNotifier {
  // Singleton setup
  static final Logicservice _instance = Logicservice._internal();
  factory Logicservice() => _instance;
  Logicservice._internal() {
    _loadPlayers();
  }

  // Persistence keys
  static const String _playersKey = 'players';

  // Variables
  List<Track> _tracks = [];
  List<Track> _trackYetToPlay = [];
  String _playlistId = '';
  Playlist? _playlist;
  int _rounds = 10; // default rounds
  bool _connected = false;
  String _token = '';
  bool get connected => _connected;
  String get token => _token;
  void setToken(String newToken) {
    _token = newToken;
    notifyListeners();
  }

  void setConnected(bool newConnected) {
    _connected = newConnected;
    notifyListeners();
  }

  List<Track> get tracks => _tracks;
  List<Track> get trackYetToPlay => _trackYetToPlay;
  String get playlistId => _playlistId;
  Playlist? get playlist => _playlist;
  int get rounds => _rounds;
  List<String> _players = [];
  void setPlayers(List<String> newPlayers) {
    _players = newPlayers;
    notifyListeners();
    _savePlayers();
  }

  void removeTrackYetToplay(Track track) {
    _trackYetToPlay.remove(track);
    notifyListeners();
  }

  List<String> get players => _players;

  void setTracks(List<Track> newTracks) {
    _tracks = newTracks;
    _trackYetToPlay = newTracks;
    notifyListeners();
  }

  void resetTracksToPlay() {
    _trackYetToPlay = _tracks;
  }

  void setPlaylistId(String id) {
    _playlistId = id;
    notifyListeners();
  }

  void setPlaylist(Playlist? playlist) {
    _playlist = playlist;
    notifyListeners();
  }

  void setRounds(int r) {
    _rounds = r;
    notifyListeners();
  }

  Future<void> _savePlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_playersKey, _players);
    } catch (_) {
      // ignore persistence errors
    }
  }

  Future<void> _loadPlayers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_playersKey);
      if (saved != null) {
        _players = saved;
        notifyListeners();
      }
    } catch (_) {
      // ignore persistence errors
    }
  }
}
