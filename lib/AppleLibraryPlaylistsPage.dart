import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:hitsterclone/services/AppleMusicService.dart';

class AppleLibraryPlaylistsPage extends StatefulWidget {
  const AppleLibraryPlaylistsPage({super.key});

  @override
  State<AppleLibraryPlaylistsPage> createState() => _AppleLibraryPlaylistsPageState();
}

class _AppleLibraryPlaylistsPageState extends State<AppleLibraryPlaylistsPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Playlist> _all = [];
  List<Playlist> _results = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLibraryPlaylists();
  }

  Future<void> _loadLibraryPlaylists() async {
    try {
      final maps = await AppleMusicService().getUserPlaylists();
      final list = maps.map((p) => Playlist(
            id: p['id'] as String? ?? '',
            name: p['name'] as String? ?? 'UNNAMED',
            imageUrl: p['imageUrl'] as String?,
          )).toList();
      setState(() {
        _all = list;
        _results = list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _all = [];
        _results = [];
        _loading = false;
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final q = value.trim().toLowerCase();
      if (q.isEmpty) {
        setState(() => _results = _all);
      } else {
        setState(() {
          _results = _all.where((p) => p.name.toLowerCase().contains(q)).toList();
        });
      }
    });
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
      builder: (_) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            const CupertinoActivityIndicator(),
            const SizedBox(height: 12),
            const Text('Lade Playlist Songs…'),
            const SizedBox(height: 4),
            Text(
              'Das kann einen Moment dauern.',
              style: TextStyle(
                fontSize: 12,
                color: CupertinoColors.systemGrey.resolveFrom(context),
              ),
            ),
          ],
        ),
      ),
    );

    try {
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
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Playlists',
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
                    child: _loading
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
                                itemBuilder: (context, index) => _playlistRow(
                                  _results[index],
                                  onTap: () => _confirmThenSelectPlaylist(
                                    _results[index],
                                  ),
                                ),
                              )),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _playlistRow(Playlist playlist, {VoidCallback? onTap}) {
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
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: (playlist.imageUrl != null && playlist.imageUrl!.isNotEmpty)
                    ? Image.network(
                        playlist.imageUrl!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        color: const Color(0xFFE5E7EB),
                        child: Text(
                          playlist.name.isNotEmpty ? playlist.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  playlist.name,
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