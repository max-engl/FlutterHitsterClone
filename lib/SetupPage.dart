import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitsterclone/AddPlayersPage.dart';
import 'package:hitsterclone/GamePage.dart';
import 'package:hitsterclone/PlaylistSourcePage.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  void _showMinimumPlayersDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => const CupertinoAlertDialog(
        title: Text('Mindestens 2 Spieler benötigt'),
        content: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Bitte füge mindestens zwei Spieler hinzu, um zu starten.',
          ),
        ),
        actions: [CupertinoDialogAction(child: Text('OK'))],
      ),
    );
  }

  void _showPlaylistRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Playlist benötigt'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Bitte wähle eine Playlist, um zu starten.'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Playlist wählen'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PlaylistSourcePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRoundsRequiredDialog(BuildContext context, Logicservice logic) {
    final maxRounds = logic.tracks.length;
    final message = maxRounds > 0
        ? 'Bitte setze die Rundenanzahl (1 bis $maxRounds).'
        : 'Bitte setze die Rundenanzahl (1+).';
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Rundenanzahl benötigt'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(message),
        ),
        actions: [
          CupertinoDialogAction(child: const Text('Abbrechen')),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Einstellen'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _showRoundsDialog(context, logic);
            },
          ),
        ],
      ),
    );
  }

  void _showRoundsDialog(BuildContext context, Logicservice logic) {
    final maxRounds = logic.tracks.length;
    final controller = TextEditingController(text: logic.rounds.toString());
    String? errorText;

    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return CupertinoAlertDialog(
              title: const Text('Runden Anzahl'),
              content: Column(
                children: [
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: CupertinoTextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      placeholder: maxRounds > 0 ? '1 bis $maxRounds' : '1+',
                      textAlign: TextAlign.center,
                      autofocus: true,
                    ),
                  ),
                  if (errorText != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      errorText!,
                      style: const TextStyle(color: CupertinoColors.systemRed),
                    ),
                  ],
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Abbrechen'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Bestätigen'),
                  onPressed: () {
                    final value = int.tryParse(controller.text.trim());
                    if (value == null || value < 1) {
                      setState(() => errorText = 'Zahl >= 1 erforderlich.');
                      return;
                    }
                    if (maxRounds > 0 && value > maxRounds) {
                      setState(() => errorText = 'Maximal $maxRounds möglich.');
                      return;
                    }
                    logic.setRounds(value);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSpotifyRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Spotify benötigt'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text('Bitte verbinde dich mit Spotify.'),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Verbinden'),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final token = await WebApiService().fetchSpotifyAccessToken();
              if (token == null || token.isEmpty) {
                _showSpotifyRequiredDialog(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        final bool isAuthorized = logic.token.isNotEmpty;
        final String spotifyStatus = isAuthorized
            ? 'Verbunden'
            : 'Nicht verbunden';

        final int maxRounds = logic.tracks.length;
        if (logic.rounds > maxRounds && maxRounds > 0) {
          logic.setRounds(maxRounds);
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
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
                  const Text(
                    "HIPSTER",
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'MUSIK. WISSEN. SPASS.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      children: [
                        _settingsRow(
                          FontAwesomeIcons.spotify,
                          "Spotify",
                          spotifyStatus,
                          onTap: () async {
                            final token = await WebApiService()
                                .fetchSpotifyAccessToken();
                            if (token == null || token.isEmpty) {
                              _showSpotifyRequiredDialog(context);
                            }
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "🫱",
                          "Spieler",
                          logic.players.length.toString(),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddPlayersPage(),
                            ),
                          ),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "📀",
                          "Playlist",
                          logic.playlist?.name ?? '',
                          onTap: () {
                            if (!isAuthorized) {
                              _showSpotifyRequiredDialog(context);
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PlaylistSourcePage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "🎮",
                          "Runden Anzahl",
                          logic.rounds.toString(),
                          onTap: () => _showRoundsDialog(context, logic),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      if (logic.players.length < 2) {
                        _showMinimumPlayersDialog(context);
                        return;
                      }
                      if (logic.playlist == null) {
                        _showPlaylistRequiredDialog(context);
                        return;
                      }
                      if (!isAuthorized) {
                        _showSpotifyRequiredDialog(context);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(rounds: logic.rounds),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text("Spiel starten"),
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
    dynamic icon,
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
            icon is IconData
                ? Icon(icon, size: 22, color: Color.fromRGBO(27, 203, 82, 1))
                : Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              value.length > 13 ? '${value.substring(0, 13)}…' : value,
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
