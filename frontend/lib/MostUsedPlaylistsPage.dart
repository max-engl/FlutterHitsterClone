import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';

class MostUsedPlaylistsPage extends StatefulWidget {
  const MostUsedPlaylistsPage({super.key});

  @override
  State<MostUsedPlaylistsPage> createState() => _MostUsedPlaylistsPageState();
}

class _MostUsedPlaylistsPageState extends State<MostUsedPlaylistsPage> {
  List<Playlist> playlists = [];
  bool isLoading = true;
  String? errorMessage;
  final Map<String, int> usageById = {};

  @override
  void initState() {
    super.initState();
    _loadMostUsedPlaylists();
  }

  Future<void> _loadMostUsedPlaylists() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final baseUrl = dotenv.env['BACKEND_URL'];
      print(baseUrl);
      final uri = Uri.parse('$baseUrl/playlist');
      final res = await http.get(uri);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        setState(() {
          errorMessage = 'Fehler: ${res.statusCode}';
          isLoading = false;
        });
        return;
      }
      final data = jsonDecode(res.body);
      print(data);
      final list = (data is List) ? data : [];
      final mapped = list.map((e) {
        final m = (e is Map<String, dynamic>) ? e : <String, dynamic>{};
        final id =
            (m['playlistId'] as String?) ??
            (m['playListID'] as String?) ??
            (m['id'] as String?) ??
            '';
        final name = m['name'] as String? ?? 'UNBENANNT';
        final desc = m['description'] as String?;
        final img = m['imageUrl'] as String?;
        final used = (m['amountUsed'] as int?) ?? 0;
        if (id.isNotEmpty) usageById[id] = used;
        return Playlist(id: id, name: name, description: desc, imageUrl: img);
      }).toList();
      setState(() {
        playlists = mapped.where((p) => p.id.isNotEmpty).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _handlePlaylistTap(Playlist playlist) async {
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
    if (confirmed != true) return;

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 8),
            CupertinoActivityIndicator(),
            SizedBox(height: 12),
            Text('Lade Playlist Songs…'),
            SizedBox(height: 4),
            Text('Das kann einen Moment dauern.'),
          ],
        ),
      ),
    );

    String token = Logicservice().token;
    if (token.isEmpty) {
      final fetchedToken = await WebApiService().fetchSpotifyAccessToken();
      if (fetchedToken == null || fetchedToken.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      WebApiService().setToken(fetchedToken);
    }

    final tracks = await WebApiService().getPlaylistTracks(playlist.id, true);
    if (mounted) Navigator.of(context).pop();
    if (tracks.isEmpty) return;

    Logicservice().setTracks(tracks);
    Logicservice().setPlaylistId(playlist.id);
    Logicservice().setPlaylist(playlist);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SetupPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text(
          'Meist verwendet',
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
              Expanded(
                child:
                    Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: isLoading
                                ? const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child: CupertinoActivityIndicator(),
                                    ),
                                  )
                                : (playlists.isEmpty
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
                                              itemCount: playlists.length,
                                              separatorBuilder: (_, __) =>
                                                  const Divider(
                                                    height: 1,
                                                    thickness: 0.5,
                                                  ),
                                              itemBuilder: (context, index) =>
                                                  _playlistRow(
                                                    playlists[index],
                                                    used:
                                                        usageById[playlists[index]
                                                            .id] ??
                                                        0,
                                                    onTap: () =>
                                                        _handlePlaylistTap(
                                                          playlists[index],
                                                        ),
                                                  ),
                                            )
                                            .animate()
                                            .fade(duration: 400.ms)
                                            .slideY(begin: 0.1, end: 0)),
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms)
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
    );
  }

  static Widget _playlistRow(
    Playlist playlist, {
    VoidCallback? onTap,
    int? used,
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
              Text(
                '${used ?? 0}×',
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.black38, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
