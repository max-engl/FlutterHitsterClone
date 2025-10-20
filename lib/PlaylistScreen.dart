import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hitsterclone/BeforeGamePage.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:hitsterclone/theme/app_theme.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({super.key});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Playlist> playlists = [];
  bool isLoading = true;
  String? errorMessage;
  Playlist? selectedPlaylist;
  final WebApiService api = WebApiService();

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  Future<void> _handlePlaylistTap(Playlist playlist) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return CupertinoAlertDialog(
          title: const Text('Playlist auswählen'),
          content: Text(
            'Möchtest du die Playlist "${playlist.name ?? 'Unbekannt'}" wählen?',
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

    if (confirmed != true) return;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return const CupertinoAlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              CupertinoActivityIndicator(),
              SizedBox(height: 12),
              Text('Lade Playlist Songs…'),
            ],
          ),
        );
      },
    );

    final tracks = await api.getPlaylistTracks(playlist.id);
    if (mounted) Navigator.of(context).pop();
    if (tracks.isEmpty) return;

    Logicservice().setTracks(tracks);
    Logicservice().setPlaylistId(playlist.id);
    Logicservice().setPlaylist(playlist);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetupPage()),
    );
  }

  Future<void> _loadPlaylists() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      String token = Logicservice().token;
      if (token.isEmpty) {
        final fetchedToken = await WebApiService().fetchSpotifyAccessToken();
        if (fetchedToken == null || fetchedToken.isEmpty) {
          setState(() {
            errorMessage = 'Failed to acquire Spotify token.';
            isLoading = false;
          });
          return;
        }
        api.setToken(fetchedToken);
      } else {
        api.setToken(token);
      }

      final fetched = await api.getUserPlaylists();
      setState(() {
        playlists = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'DEINE PLAYLISTS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: ClipRect(
              child: Container(
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
                child: Container(
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
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [const CupertinoActivityIndicator()],
                          ),
                        )
                      : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppTheme.kDefaultPadding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'FAILED TO LOAD',
                                  style: AppTheme.subheadingStyle,
                                ),
                                SizedBox(height: AppTheme.kSmallSpacing),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: AppTheme.kDefaultSpacing),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _loadPlaylists,
                                    style: AppTheme.primaryButtonStyle,
                                    child: Text(
                                      'RETRY',
                                      style: AppTheme.buttonTextStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: playlists.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1, thickness: 0.5),
                                itemBuilder: (context, index) {
                                  final playlist = playlists[index];
                                  return _playlistRow(
                                    playlist,
                                    onTap: () => _handlePlaylistTap(playlist),
                                  );
                                },
                              ),
                            ),
                            // Bottom action removed; selection via dialog on tap
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _playlistRow(Playlist playlist, {VoidCallback? onTap}) {
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
