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
import 'package:hitsterclone/SpotifyAuthPage.dart';
import 'package:hitsterclone/services/WebApiService.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  void _showMinimumPlayersDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Mindestens 2 Spieler benötigt'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Bitte füge mindestens zwei Spieler hinzu, um zu starten.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
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
          child: Text(
            'Bitte wähle eine Playlist, um zu starten.',
            textAlign: TextAlign.center,
          ),
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
          child: Text(message, textAlign: TextAlign.center),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
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
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: CupertinoTextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        placeholder: maxRounds > 0 ? '1 bis $maxRounds' : '1+',
                        textAlign: TextAlign.center,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {},
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        errorText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
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
                    final text = controller.text.trim();
                    final value = int.tryParse(text);
                    if (value == null || value < 1) {
                      setState(() {
                        errorText = 'Bitte eine gültige Zahl (≥ 1) eingeben.';
                      });
                      return;
                    }
                    if (maxRounds > 0 && value > maxRounds) {
                      setState(() {
                        errorText = 'Maximal $maxRounds Runden möglich.';
                      });
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
          child: Text(
            'Bitte verbinde dich mit Spotify, um das Spiel zu starten.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Abbrechen'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Mit Spotify verbinden'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _connectOrCheckSpotify(context);
            },
          ),
        ],
      ),
    );
  }

  void _showActiveDeviceRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Kein aktives Gerät gefunden'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Bitte öffne Spotify auf einem Gerät und starte die Wiedergabe. Danach versuche es erneut.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _connectOrCheckSpotify(BuildContext context) async {
    // Try to authorize if token is missing, otherwise refresh device status
    try {
      String token = Logicservice().token;
      if (token.isEmpty) {
        final fetched = await WebApiService().fetchSpotifyAccessToken();
        if (fetched == null || fetched.isEmpty) {
          _showSpotifyRequiredDialog(context);
          return;
        }
        WebApiService().setToken(fetched);
      }
      // Refresh connection and attempt to activate a device
      await WebApiService().ensureConnected(force: true);
      await WebApiService().ensureActiveDevice(force: true);

      // Show current status
      final isConnected = Logicservice().connected;
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Spotify Status'),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              isConnected
                  ? 'Verbunden. Gerät erkannt.'
                  : 'Verbunden, aber kein Gerät erkannt.',
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSpotifyRequiredDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        // Clamp rounds to the available tracks length if needed
        final int maxRounds = logic.tracks.length;
        final int currentRounds = logic.rounds;
        if (currentRounds > maxRounds && maxRounds > 0) {
          logic.setRounds(maxRounds);
        }

        final bool isAuthorized = logic.token.isNotEmpty;
        final bool isConnected = logic.connected;
        final String spotifyStatus = !isAuthorized
            ? 'Nicht verbunden'
            : (isConnected ? 'Verbunden' : 'Verbunden');

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
                  Text(
                    "HIPSTER",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
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
                          FontAwesomeIcons.spotify,
                          "Spotify",
                          spotifyStatus,
                          onTap: () => _connectOrCheckSpotify(context),
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "🫱",
                          "Spieler",
                          Logicservice().players.length.toString(),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddPlayersPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, thickness: 0.5),
                        _settingsRow(
                          "📀",
                          "Playlist",
                          Logicservice().playlist?.name ?? '',
                          onTap: () {
                            if (Logicservice().token.isEmpty) {
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
                      final playerCount = logic.players.length;
                      if (playerCount < 2) {
                        _showMinimumPlayersDialog(context);
                        return;
                      }

                      if (logic.playlist == null) {
                        _showPlaylistRequiredDialog(context);
                        return;
                      }

                      final int maxRounds = logic.tracks.length;
                      final int rounds = logic.rounds;
                      if (maxRounds < 1) {
                        _showPlaylistRequiredDialog(context);
                        return;
                      }
                      if (rounds < 1 || rounds > maxRounds) {
                        _showRoundsRequiredDialog(context, logic);
                        return;
                      }

                      // Require Spotify auth and an active device
                      if (logic.token.isEmpty) {
                        _showSpotifyRequiredDialog(context);
                        return;
                      }
                      final hasActive = await WebApiService()
                          .ensureActiveDevice(force: true);
                      if (!hasActive) {
                        _showActiveDeviceRequiredDialog(context);
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GamePage(rounds: rounds),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
    dynamic icon, // String emoji OR IconData
    String title,
    String value, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
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
                  color: Colors.black,
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
