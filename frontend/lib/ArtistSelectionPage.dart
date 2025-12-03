import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';

class ArtistSelectionPage extends StatefulWidget {
  const ArtistSelectionPage({super.key});

  @override
  State<ArtistSelectionPage> createState() => _ArtistSelectionPageState();
}

class _ArtistSelectionPageState extends State<ArtistSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Artist> _results = [];
  bool _isSearching = false;
  bool _multiArtists = false;
  final Set<String> _selectedArtistIds = {};
  final Map<String, Artist> _selectedArtists = {};
  bool _filterSelectedOnly = false;
  bool _isFetching = false;
  int _fetchTotal = 0;
  int _fetchProcessed = 0;

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

    final artists = await WebApiService().searchArtist(trimmed);
    setState(() {
      _results = artists;
      _isSearching = false;
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(value);
    });
  }

  Future<void> _selectArtist(Artist artist) async {
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
            const Text('Lade Künstler Songs…'),
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
    print(
      'Selected artist: ${artist.name} (id: ${artist.id}, imageUrl: ${artist.imageUrl})',
    );
    final tracks = await WebApiService().getArtistTrackUrisById(artist.id);

    if (mounted) Navigator.of(context).pop();

    if (tracks.isEmpty) return;
    // Print artist details

    // Save and navigate
    Logicservice().setTracks(tracks);
    Logicservice().setPlaylist(
      Playlist(id: artist.id, name: artist.name, imageUrl: artist.imageUrl),
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
                "Artist",
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
                        placeholder: 'Suche nach Künstler...',
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
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.person_2,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              "Mehrere Artists?",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (_multiArtists)
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              onPressed: () => setState(
                                () =>
                                    _filterSelectedOnly = !_filterSelectedOnly,
                              ),
                              child: Icon(
                                _filterSelectedOnly
                                    ? CupertinoIcons
                                          .line_horizontal_3_decrease_circle_fill
                                    : CupertinoIcons
                                          .line_horizontal_3_decrease_circle,
                                color: _filterSelectedOnly
                                    ? const Color(0xFF5A3EFF)
                                    : Colors.black54,
                                size: 24,
                              ),
                            ),
                          const SizedBox(width: 8),
                          CupertinoSwitch(
                            value: _multiArtists,
                            onChanged: (v) => setState(() {
                              _multiArtists = v;
                              if (!v) {
                                _selectedArtistIds.clear();
                                _selectedArtists.clear();
                                _filterSelectedOnly = false;
                              }
                            }),
                            activeColor: const Color(0xFF5A3EFF),
                          ),
                        ],
                      ),
                    ),
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
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.separated(
                                        itemCount: (_filterSelectedOnly
                                            ? _selectedArtists.length
                                            : _results.length),
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                              height: 1,
                                              thickness: 0.5,
                                            ),
                                        itemBuilder: (context, index) {
                                          final display = _filterSelectedOnly
                                              ? _selectedArtists.values.toList()
                                              : _results;
                                          final artist = display[index];
                                          final selected = _selectedArtistIds
                                              .contains(artist.id);
                                          return _artistRow(
                                            artist,
                                            selected: selected,
                                            onTap: () {
                                              if (_multiArtists) {
                                                _toggleArtistSelection(artist);
                                              } else {
                                                _confirmThenSelectArtist(
                                                  artist,
                                                );
                                              }
                                            },
                                          );
                                        },
                                      )),
                        ),
                      ),
                    ),
                    if (_multiArtists && _selectedArtistIds.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: ElevatedButton(
                          onPressed: _finishMultiSelection,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 52),
                          ),
                          child: const Text(
                            "Fertig",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                    else
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

  static Widget _artistRow(
    Artist artist, {
    VoidCallback? onTap,
    bool selected = false,
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
              if (artist.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    artist.imageUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  artist.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              selected
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      color: Colors.black87,
                      size: 22,
                    )
                  : const Icon(
                      Icons.chevron_right,
                      color: Colors.black38,
                      size: 22,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmArtistSelection(Artist artist) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Künstler auswählen'),
        content: Text(
          'Möchtest du den Künstler "${artist.name}" wählen?',
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
      ),
    );
    return confirmed == true;
  }

  Future<void> _confirmThenSelectArtist(Artist artist) async {
    final ok = await _confirmArtistSelection(artist);
    if (ok) {
      await _selectArtist(artist);
    }
  }

  void _toggleArtistSelection(Artist artist) {
    setState(() {
      if (_selectedArtistIds.contains(artist.id)) {
        _selectedArtistIds.remove(artist.id);
        _selectedArtists.remove(artist.id);
      } else {
        _selectedArtistIds.add(artist.id);
        _selectedArtists[artist.id] = artist;
      }
    });
  }

  Future<void> _finishMultiSelection() async {
    if (_selectedArtistIds.isEmpty) return;
    final names = _selectedArtistIds
        .map((id) => _selectedArtists[id]?.name ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    final ok = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Bestätigen'),
        content: Text(
          'Wirklich alle Songs der folgenden Künstler laden?\nDas kann eine Weile dauern.\n\n${names.map((n) => '• ' + n).join('\n')}',
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
            child: const Text('Laden'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    setState(() {
      _isFetching = true;
      _fetchTotal = _selectedArtistIds.length;
      _fetchProcessed = 0;
    });

    final processedNotifier = ValueNotifier<int>(0);
    final total = _fetchTotal;
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
            ValueListenableBuilder<int>(
              valueListenable: processedNotifier,
              builder: (context, value, _) => Column(
                children: [
                  Text(
                    'Lade Künstler $value/$total',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: total == 0
                        ? null
                        : (value / (total == 0 ? 1 : total)),
                    minHeight: 4,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF5A3EFF),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    try {
      String token = Logicservice().token;
      if (token.isEmpty) {
        final fetched = await WebApiService().fetchSpotifyAccessToken();
        if (fetched == null || fetched.isEmpty) {
          if (mounted) Navigator.of(context).pop();
          setState(() => _isFetching = false);
          return;
        }
        WebApiService().setToken(fetched);
      }

      final List<Track> allTracks = [];
      final Set<String> seenUris = {};
      final ids = _selectedArtistIds.toList();
      const int maxConcurrent = 4;
      for (int i = 0; i < ids.length; i += maxConcurrent) {
        final int end = (i + maxConcurrent) > ids.length
            ? ids.length
            : (i + maxConcurrent);
        final batchIds = ids.sublist(i, end);
        final batchResults = await Future.wait(
          batchIds.map((id) async {
            final tracks = await WebApiService().getArtistTrackUrisById(id);
            processedNotifier.value = processedNotifier.value + 1;
            return tracks;
          }),
        );
        for (final tracks in batchResults) {
          for (final t in tracks) {
            if (!seenUris.contains(t.uri)) {
              seenUris.add(t.uri);
              allTracks.add(t);
            }
          }
        }
      }

      if (mounted) Navigator.of(context).pop();
      setState(() => _isFetching = false);
      if (allTracks.isEmpty) return;

      Logicservice().setTracks(allTracks);
      Logicservice().setPlaylist(
        Playlist(id: 'multi_artists', name: 'Mehrere Künstler', imageUrl: null),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SetupPage()),
      );
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      setState(() => _isFetching = false);
    }
  }
}
