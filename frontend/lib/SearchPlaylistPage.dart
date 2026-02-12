import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchPlaylistPage extends StatefulWidget {
  const SearchPlaylistPage({super.key});

  @override
  State<SearchPlaylistPage> createState() => _SearchPlaylistPageState();
}

class _SearchPlaylistPageState extends State<SearchPlaylistPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Playlist> _results = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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

    // Ensure token exists
    String token = Logicservice().token;
    if (token.isEmpty) {
      final fetched = await WebApiService().fetchSpotifyAccessToken();
      if (fetched == null || fetched.isEmpty) {
        setState(() => _isSearching = false);
        return;
      }
      WebApiService().setToken(fetched);
    }

    final playlists = await WebApiService().searchPublicPlaylists(trimmed);
    setState(() {
      _results = playlists.map((json) => Playlist.fromJson(json)).toList();
      _isSearching = false;
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(value);
    });
  }

  Future<void> _selectArtist(Playlist playlist) async {
    // Show progress dialog
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

    // Ensure token exists
    String token = Logicservice().token;
    if (token.isEmpty) {
      final fetched = await WebApiService().fetchSpotifyAccessToken();
      if (fetched == null || fetched.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      WebApiService().setToken(fetched);
    }

    final tracks = await WebApiService().getPlaylistTracks(playlist.id, true);

    if (mounted) Navigator.of(context).pop();

    if (tracks.isEmpty) return;

    // Save and navigate
    Logicservice().setTracks(tracks);
    Logicservice().setPlaylist(
      Playlist(
        id: playlist.id,
        name: playlist.name,
        imageUrl: playlist.imageUrl,
      ),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        return WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text(
                "Playlists",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF9A7BFF),
                    Color(0xFF7A5EFF),
                    Color(0xFF5A3EFF),
                  ],
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
                        )
                        .animate()
                        .fade(duration: 400.ms)
                        .slideY(begin: -0.5, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    Expanded(
                      child:
                          Container(
                                clipBehavior: Clip.hardEdge,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: _isSearching
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
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ListView.separated(
                                                    itemCount: _results.length,
                                                    separatorBuilder: (_, __) =>
                                                        const Divider(
                                                          height: 1,
                                                          thickness: 0.5,
                                                        ),
                                                    itemBuilder:
                                                        (
                                                          context,
                                                          index,
                                                        ) => _artistRow(
                                                          _results[index],
                                                          onTap: () =>
                                                              _confirmThenSelectPlaylist(
                                                                _results[index],
                                                              ),
                                                        ),
                                                  )
                                                  .animate()
                                                  .fade(duration: 400.ms)
                                                  .slideY(begin: 0.1, end: 0)),
                                ),
                              )
                              .animate()
                              .fade(delay: 200.ms, duration: 600.ms)
                              .scale(
                                begin: const Offset(0.95, 0.95),
                                curve: Curves.easeOutBack,
                              ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _artistRow(Playlist playlist, {VoidCallback? onTap}) {
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
              if (playlist.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    playlist.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
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
    if (ok) {
      await _selectArtist(playlist);
    }
  }
}
