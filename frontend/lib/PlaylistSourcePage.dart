import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hitsterclone/ArtistSelectionPage.dart';
import 'package:hitsterclone/PlaylistScreen.dart';
import 'package:hitsterclone/SelectedSongsPage.dart';
import 'package:hitsterclone/SearchPlaylistPage.dart';
import 'package:hitsterclone/MostUsedPlaylistsPage.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';

class PlaylistSourcePage extends StatelessWidget {
  const PlaylistSourcePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (Logicservice().playlist != null)
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectedSongsPage(),
                          ),
                        );
                      },
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
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  if (Logicservice().playlist?.imageUrl != null)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        Logicservice().playlist?.imageUrl ??
                                            'NONE',
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      Logicservice().playlist?.name != null &&
                                              Logicservice()
                                                      .playlist!
                                                      .name!
                                                      .length >
                                                  13
                                          ? '${Logicservice().playlist!.name!.substring(0, 13)}...'
                                          : Logicservice().playlist?.name ??
                                                'NO NAME',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    Logicservice().tracks?.length.toString() ??
                                        "-1",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.black38,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    "Wähle die Quelle der gewünschten Playlist aus!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _settingsRow(
                          "🧑‍🎨",
                          "Artist",
                          "Alle songs!",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ArtistSelectionPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "📈",
                          "Meist verwendet",
                          "",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MostUsedPlaylistsPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "🫵",
                          "Deine Playlists",
                          "",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlaylistScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "🎮",
                          "Öffentliche Playlists",
                          "",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SearchPlaylistPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _settingsRow(
    String emoji,
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}
