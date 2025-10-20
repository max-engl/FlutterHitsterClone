import 'package:flutter/material.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/PlaylistScreen.dart';
import 'package:hitsterclone/PlaylistSourcePage.dart';
import 'package:hitsterclone/GamePage.dart';
import 'package:hitsterclone/AddPlayersPage.dart';
import 'package:hitsterclone/theme/app_theme.dart';
import 'package:hitsterclone/services/SpotifyService.dart';
import 'package:hitsterclone/services/LogicService.dart';

class BeforeGamePage extends StatefulWidget {
  const BeforeGamePage({super.key});

  @override
  State<BeforeGamePage> createState() => _BeforeGamePageState();
}

// ---- Moved Player selection screen here to keep related UI together ----
// Player selection moved to its own page (AddPlayersPage.dart)

class _BeforeGamePageState extends State<BeforeGamePage> {
  bool _loadingToken = false;
  int _rounds = 1;

  Future<void> _goToPlaylistSelection() async {
    setState(() => _loadingToken = true);
    try {
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PlaylistSourcePage()),
      );
    } finally {
      if (mounted) setState(() => _loadingToken = false);
    }
  }

  Future<void> _goToGame() async {
    // Ensure there is an active Spotify device before starting the game
    final hasActive = await WebApiService().ensureActiveDevice(force: true);
    if (!hasActive) {
      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) {
          return Dialog(
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.kDefaultPadding,
              vertical: AppTheme.kDefaultPadding,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              decoration: AppTheme.containerDecoration(isHighlighted: true),
              padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'NO ACTIVE SPOTIFY DEVICE',
                    style: AppTheme.subheadingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.kSmallSpacing),
                  const Text(
                    'Open Spotify on your device and start playing a song. '
                    'Then return here and tap TRY AGAIN.',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: AppTheme.primaryButtonStyle,
                      child: Text('TRY AGAIN', style: AppTheme.buttonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          final players = context.read<Logicservice>().players;
          return GamePage(rounds: _rounds);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CHOOSE PLAYLIST',
          style: TextStyle(letterSpacing: 2.0),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
        child: Consumer<Logicservice>(
          builder: (context, logic, child) {
            final hasSelection = logic.playlist != null;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Players information (read-only here)
                  Text(
                    'PLAYERS: ${logic.players.length}',
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (hasSelection && logic.playlist!.imageUrl != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Image.network(
                              logic.playlist!.imageUrl!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                          ),
                        Text(
                          hasSelection
                              ? logic.playlist!.name ?? 'UNKNOWN'
                              : 'NO PLAYLIST SELECTED',
                          style: AppTheme.subheadingStyle,
                          textAlign: TextAlign.center,
                        ),
                        Text("${logic.tracks.length} Tracks"),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ROUNDS', style: AppTheme.subheadingStyle),
                        const SizedBox(height: AppTheme.kSmallSpacing),
                        if (logic.tracks.isNotEmpty) ...[
                          Slider(
                            value: (_rounds.clamp(
                              1,
                              logic.tracks.length,
                            )).toDouble(),
                            min: 1,
                            max: logic.tracks.length.toDouble(),
                            divisions: logic.tracks.length > 1
                                ? logic.tracks.length - 1
                                : null,
                            label: '${(_rounds.clamp(1, logic.tracks.length))}',
                            onChanged: (val) {
                              setState(() {
                                _rounds = val.round();
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected: ${(_rounds.clamp(1, logic.tracks.length))}',
                              ),
                              Text('Max: ${logic.tracks.length}'),
                            ],
                          ),
                        ] else ...[
                          Text(
                            'Select a playlist to set rounds',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loadingToken ? null : _goToPlaylistSelection,
                      style: hasSelection
                          ? AppTheme.secondaryButtonStyle
                          : AppTheme.primaryButtonStyle,
                      child: Text(
                        _loadingToken
                            ? 'LOADING…'
                            : (hasSelection
                                  ? 'CHANGE PLAYLIST'
                                  : 'SELECT PLAYLIST'),
                        style: hasSelection
                            ? AppTheme.buttonTextStyle.copyWith(
                                color: Colors.black,
                              )
                            : AppTheme.buttonTextStyle,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  if (hasSelection && logic.players.length >= 2)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _goToGame,
                        style: AppTheme.primaryButtonStyle,
                        child: Text(
                          'GO TO GAME',
                          style: AppTheme.buttonTextStyle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
