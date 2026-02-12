import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hitsterclone/AddPlayersPage.dart';
import 'package:hitsterclone/GamePage.dart';
import 'package:hitsterclone/GameSettingsPage.dart';
import 'package:hitsterclone/PlaylistSourcePage.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPlayersPage()),
              );
            },
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

  void _showDeviceSelectionRequiredDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Gerät benötigt'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Bitte wähle ein Gerät, um das Spiel zu starten.',
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
            child: const Text('Gerät wählen'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _connectOrCheckSpotify(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _connectOrCheckSpotify(BuildContext context) async {
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

      await WebApiService().ensureConnected(force: true);
      final devices = await WebApiService().getDevices();

      if (devices.isEmpty) {
        _showActiveDeviceRequiredDialog(context);
        return;
      }

      final selectedDevice =
          await showCupertinoModalPopup<Map<String, dynamic>>(
            context: context,
            builder: (ctx) {
              return CupertinoActionSheet(
                title: const Text('Gerät wählen'),
                message: const Text(
                  'Wähle ein Spotify Gerät für die Wiedergabe.',
                ),
                actions: devices.map((d) {
                  final name = (d['name'] as String?) ?? 'Unbekannt';
                  final type = (d['type'] as String?) ?? '';
                  final isActive = d['is_active'] == true;
                  final label = isActive
                      ? '$name${type.isNotEmpty ? ' • $type' : ''} (aktiv)'
                      : '$name${type.isNotEmpty ? ' • $type' : ''}';
                  return CupertinoActionSheetAction(
                    onPressed: () => Navigator.of(ctx).pop(d),
                    child: Text(label),
                  );
                }).toList(),
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Abbrechen'),
                ),
              );
            },
          );

      if (selectedDevice != null) {
        final id = selectedDevice['id'] as String?;
        final name = (selectedDevice['name'] as String?) ?? 'Gerät';
        if (id != null) {
          final ok = await WebApiService().transferPlaybackTo(id, play: true);
          await WebApiService().ensureConnected(force: true);
          if (ok) {
            Logicservice().setPreferredDeviceId(id);
            Logicservice().setCurrentDeviceName(name);
          }

          await showCupertinoDialog(
            context: context,
            builder: (ctx) => CupertinoAlertDialog(
              title: const Text('Gerät ausgewählt'),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  ok
                      ? 'Wiedergabe auf "$name" gestartet.'
                      : 'Gerät konnte nicht aktiviert werden.',
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
      }
    } catch (e) {
      _showSpotifyRequiredDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
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

        final String deviceName = logic.currentDeviceName ?? '';

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
                  SizedBox(height: 30),
                  Text(
                        "HIPSTER",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      )
                      .animate()
                      .fade(duration: 800.ms)
                      .slideY(begin: -0.5, end: 0, curve: Curves.easeOutBack)
                      .shimmer(delay: 1000.ms, duration: 1500.ms),

                  SizedBox(
                        height: 50,
                        child: Marquee(
                          text: 'Musik 🎶 Wissen 🎵 Spaß 🎵 ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.1,
                          ),
                          scrollAxis: Axis.horizontal,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          velocity: 50.0,

                          startPadding: 10.0,

                          fadingEdgeEndFraction: 0.5,
                          fadingEdgeStartFraction: 0.5,
                        ),
                      )
                      .animate()
                      .fade(delay: 200.ms, duration: 600.ms)
                      .slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 16),
                  Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children:
                              [
                                    _settingsRow(
                                      FontAwesomeIcons.spotify,
                                      "Spotify",
                                      spotifyStatus,
                                      onTap: () =>
                                          _connectOrCheckSpotify(context),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    _settingsRow(
                                      "📱",
                                      "Spiel-Gerät",
                                      deviceName,
                                      onTap: () =>
                                          _connectOrCheckSpotify(context),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    _settingsRow(
                                      "🫱",
                                      "Spieler",
                                      Logicservice().players.length.toString(),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const AddPlayersPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                      ),
                                    ),
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Divider(
                                        height: 1,
                                        thickness: 0.5,
                                      ),
                                    ),
                                    _settingsRow(
                                      "⚙️",
                                      "Spiel-Einstellungen",
                                      "",
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const GameSettingsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ]
                                  .animate(interval: 50.ms)
                                  .fade(duration: 400.ms)
                                  .slideX(
                                    begin: 0.1,
                                    end: 0,
                                    curve: Curves.easeOut,
                                  ),
                        ),
                      )
                      .animate()
                      .fade(delay: 400.ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        delay: 400.ms,
                        curve: Curves.easeOutBack,
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

                          // Require Spotify auth and a selected device
                          if (logic.token.isEmpty) {
                            _showSpotifyRequiredDialog(context);
                            return;
                          }
                          if (logic.preferredDeviceId == null) {
                            _showDeviceSelectionRequiredDialog(context);
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
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text("Spiel starten"),
                      )
                      .animate()
                      .fade(delay: 800.ms)
                      .slideY(begin: 1, end: 0, curve: Curves.easeOutBack)
                      .shimmer(delay: 2000.ms, duration: 1500.ms),
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
