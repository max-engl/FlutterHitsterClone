import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/MusicKit.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:hitsterclone/services/AppleMusicService.dart';
import 'package:hitsterclone/SetupPage.dart';

class Appletestpage extends StatefulWidget {
  final bool startWithLibrary;
  const Appletestpage({super.key, this.startWithLibrary = false});

  @override
  State<Appletestpage> createState() => _AppletestpageState();
}

class _AppletestpageState extends State<Appletestpage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _results = [];
  bool _isSearching = false;
  bool _libraryMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          foregroundColor: Colors.white,
          title: const Text(
            'Apple Music Playlists',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF9A7BFF), Color(0xFF7A5EFF), Color(0xFF5A3EFF)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                if (!_libraryMode)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: CupertinoTextField(
                      controller: _searchController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      placeholder: 'Suche nach Playlist...',
                      placeholderStyle: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Icon(
                          CupertinoIcons.search,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                      onChanged: _onQueryChanged,
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _libraryMode
                          ? (_results.isEmpty
                              ? const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: Text(
                                      'Keine Playlists',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _results.length,
                                  separatorBuilder: (_, __) => const Divider(
                                    height: 1,
                                    thickness: 0.5,
                                  ),
                                  itemBuilder: (context, index) {
                                    final p = _results[index];
                                    return _playlistRow(
                                      name: p['name'] ?? 'Untitled',
                                      imageUrl: p['imageUrl'] as String?,
                                      onTap: () {
                                        final id = p['id'] ?? '';
                                        final name = p['name'] ?? 'Untitled';
                                        final playlist = Playlist(
                                          id: id,
                                          name: name,
                                          imageUrl: p['imageUrl'] as String?,
                                        );
                                        _confirmThenSelectPlaylist(playlist);
                                      },
                                    );
                                  },
                                ))
                          : (_isSearching
                              ? const SizedBox(
                                  height: 100,
                                  child: Center(
                                    child: CupertinoActivityIndicator(),
                                  ),
                                )
                              : (_results.isEmpty
                                  ? const SizedBox(
                                      height: 100,
                                      child: Center(
                                        child: Text(
                                          'Keine Ergebnisse',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ),
                                    )
                                  : ListView.separated(
                                      itemCount: _results.length,
                                      separatorBuilder: (_, __) => const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                      ),
                                      itemBuilder: (context, index) {
                                        final p = _results[index];
                                        return _playlistRow(
                                          name: p['name'] ?? 'Untitled',
                                          imageUrl: p['imageUrl'] as String?,
                                          onTap: () {
                                            final id = p['id'] ?? '';
                                            final name = p['name'] ?? 'Untitled';
                                            final playlist = Playlist(
                                              id: id,
                                              name: name,
                                              imageUrl: p['imageUrl'] as String?,
                                            );
                                            _confirmThenSelectPlaylist(playlist);
                                          },
                                        );
                                      },
                                    ))),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(value);
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _results = [];
      });
      return;
    }
    setState(() => _isSearching = true);
    try {
      final res = await MusicKit.searchCatalogPlaylists(trimmed);
      final normalized = res
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      setState(() {
        _results = normalized;
        _isSearching = false;
      });
    } catch (e) {
      setState(() => _isSearching = false);
    }
  }

  Future<bool> _confirmPlaylistSelection(Playlist playlist) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: const Text('Playlist auswählen'),
          content: Text(
            'Möchtest du die Playlist "${playlist.name}" wählen?',
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Abbrechen'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Auswählen'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  Future<void> _confirmThenSelectPlaylist(Playlist playlist) async {
    final ok = await _confirmPlaylistSelection(playlist);
    if (!ok) return;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8),
            CupertinoActivityIndicator(),
            SizedBox(height: 12),
            Text('Lade Playlist Songs…'),
          ],
        ),
      ),
    );

    try {
      // Set selected playlist immediately for UI sync
      Logicservice().setPlaylist(playlist);
      final tracks = await AppleMusicService().getPlaylistTracksModel(playlist.id);
      if (mounted) Navigator.of(context).pop();
      Logicservice().setTracks(tracks);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupPage()),
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    _libraryMode = widget.startWithLibrary;
    if (_libraryMode) {
      _loadLibraryPlaylists();
    }
  }

  Future<void> _loadLibraryPlaylists() async {
    try {
      final res = await MusicKit.getUserPlaylists();
      final normalized = res
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
      setState(() {
        _results = normalized;
      });
    } catch (_) {}
  }

  static Widget _playlistRow({
    required String name,
    String? imageUrl,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black38, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistSongsPage extends StatefulWidget {
  final String playlistId;
  final String playlistName;
  const PlaylistSongsPage({
    super.key,
    required this.playlistId,
    required this.playlistName,
  });

  @override
  State<PlaylistSongsPage> createState() => _PlaylistSongsPageState();
}

class _PlaylistSongsPageState extends State<PlaylistSongsPage> {
  List<dynamic> songs = [];
  bool loading = true;
  String status = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await MusicKit.getPlaylistSongs(widget.playlistId);
      setState(() {
        songs = result;
        loading = false;
        status = 'Loaded ${result.length} songs';
      });
    } catch (e) {
      setState(() {
        loading = false;
        status = 'Error loading songs: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlistName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: songs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final s = songs[index];
                        final title = s['title'] ?? 'Unknown';
                        final artist = s['artist'] ?? '';
                        final album = s['album'] ?? '';
                        final id = s['id'] ?? '';
                        return ListTile(
                          title: Text(title),
                          subtitle: Text('$artist — $album'),
                          onTap: () {
                            print('id: $id, name: $title');
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () => MusicKit.playSong(id),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
