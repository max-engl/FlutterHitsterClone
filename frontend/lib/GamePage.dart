library game_page;

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/SpotifyService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:provider/provider.dart';

import 'game/widgets/game_widgets.dart';

part 'game/game_page_logic.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key, required this.rounds});

  final int rounds;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  late final GifController _controller;

  bool _connected = false;
  int currentSongIndex = 0;
  int currentState = 0;

  String? guessingPlayer;
  int? countdown;
  Timer? _timer;
  bool skippedRound = false;

  List<String> players = [];
  Track? currentSong;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _currentGif = "assets/gifs/xz.gif"; // Default GIF

  // Gradient palette and current gradient
  final List<LinearGradient> _gradientPalette = const [
    // Purples
    LinearGradient(
      colors: [Color(0xFF9A7BFF), Color(0xFF7A5EFF), Color(0xFF5A3EFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFC084FC), Color(0xFF9333EA), Color(0xFF6D28D9)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFD8B4FE), Color(0xFF7C3AED), Color(0xFF5B21B6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFB794F4), Color(0xFF805AD5), Color(0xFF553C9A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Blues
    LinearGradient(
      colors: [Color(0xFF5EA1FF), Color(0xFF2A6BFF), Color(0xFF0A3EFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF76E5FF), Color(0xFF4BC1FF), Color(0xFF2F7BFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1E40AF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF60A5FA), Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF6EE7F9), Color(0xFF5AA5FF), Color(0xFF3B66FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF93C5FD), Color(0xFF3B82F6), Color(0xFF1E3A8A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Teal / Aqua
    LinearGradient(
      colors: [Color(0xFFB2FFDA), Color(0xFF66E8A3), Color(0xFF2BBF8A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF99F6E4), Color(0xFF34D399), Color(0xFF059669)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF5EEAD4), Color(0xFF14B8A6), Color(0xFF0D9488)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF6EE7B7), Color(0xFF10B981), Color(0xFF047857)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFA7F3D0), Color(0xFF34D399), Color(0xFF065F46)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Greens
    LinearGradient(
      colors: [Color(0xFF86EFAC), Color(0xFF22C55E), Color(0xFF166534)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFBBF7D0), Color(0xFF4ADE80), Color(0xFF15803D)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFD9F99D), Color(0xFF84CC16), Color(0xFF3F6212)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFCCFBF1), Color(0xFF2DD4BF), Color(0xFF0F766E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Yellows / Oranges
    LinearGradient(
      colors: [Color(0xFFFFD57A), Color(0xFFFF9E5A), Color(0xFFFF6B3E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFDE68A), Color(0xFFFBBF24), Color(0xFFB45309)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFE08A), Color(0xFFFFB703), Color(0xFFFB8500)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFE29F), Color(0xFFFFAC33), Color(0xFFFF6F00)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFC371), Color(0xFFFFA726), Color(0xFFFB8C00)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFD6A5), Color(0xFFFFAD60), Color(0xFFFF7300)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Reds / Pinks
    LinearGradient(
      colors: [Color(0xFFFFA3A3), Color(0xFFFF6F91), Color(0xFF7E5CFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFFC0CB), Color(0xFFFF6B81), Color(0xFFDB2777)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFDA4AF), Color(0xFFF43F5E), Color(0xFFBE123C)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFF8FAB), Color(0xFFFB6F92), Color(0xFF8E3B82)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFF9EAA), Color(0xFFF15BB5), Color(0xFF9B5DE5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFF7AD1), Color(0xFFFF5FA8), Color(0xFF8E4BFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Magenta / Violet mixes
    LinearGradient(
      colors: [Color(0xFFE879F9), Color(0xFFD946EF), Color(0xFF7E22CE)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFF0ABFC), Color(0xFFE879F9), Color(0xFF9333EA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFE9D5FF), Color(0xFFC084FC), Color(0xFF9333EA)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFFBCFE8), Color(0xFFF472B6), Color(0xFFDB2777)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFFF5D0FE), Color(0xFFE879F9), Color(0xFFC026D3)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Cool Cyan to Purple transitions
    LinearGradient(
      colors: [Color(0xFF80FFEA), Color(0xFF8E7DFF), Color(0xFF7350FF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF64DFDF), Color(0xFF80FFDB), Color(0xFF5E60CE)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF7DD3FC), Color(0xFFA78BFA), Color(0xFF6D28D9)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF81E6D9), Color(0xFF63B3ED), Color(0xFF805AD5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF818CF8), Color(0xFFA855F7)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Blue to Pink gradients
    LinearGradient(
      colors: [Color(0xFF38BDF8), Color(0xFF818CF8), Color(0xFFF472B6)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF60A5FA), Color(0xFFA78BFA), Color(0xFFFB7185)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF9333EA), Color(0xFFF43F5E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF22D3EE), Color(0xFF4F46E5), Color(0xFFEC4899)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF0EA5E9), Color(0xFF6366F1), Color(0xFFDB2777)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),

    // Deep / dark gradients
    LinearGradient(
      colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF0F172A)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF312E81), Color(0xFF3730A3), Color(0xFF1E1B4B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF172554)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    LinearGradient(
      colors: [Color(0xFF2E1065), Color(0xFF4C1D95), Color(0xFF1E1B4B)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ];

  late LinearGradient _currentGradient;
  int _currentGradientIndex = -1;

  // List of available GIFs
  final List<String> _gifList = [
    "assets/gifs/1Khd.gif",
    "assets/gifs/2ull.gif",
    "assets/gifs/5EeH.gif",
    "assets/gifs/6os.gif",
    "assets/gifs/6ov.gif",
    "assets/gifs/7Uz.gif",
    "assets/gifs/IXNp.gif",
    "assets/gifs/JUd.gif",
    "assets/gifs/RqUr.gif",
    "assets/gifs/WG8Q.gif",
    "assets/gifs/X11D.gif",
    "assets/gifs/X5NZ.gif",
    "assets/gifs/XiPu.gif",
    "assets/gifs/YTup.gif",
    "assets/gifs/hdt.gif",
    "assets/gifs/xz.gif",
    "assets/gifs/y5.gif",
  ];

  // Select next gradient (avoid repeating last)
  LinearGradient _pickNextGradient() {
    final r = Random();
    int nextIndex;
    if (_gradientPalette.length <= 1) {
      nextIndex = 0;
    } else {
      do {
        nextIndex = r.nextInt(_gradientPalette.length);
      } while (nextIndex == _currentGradientIndex);
    }
    _currentGradientIndex = nextIndex;
    return _gradientPalette[nextIndex];
  }

  // Add player score tracking
  Map<String, int> playerScores = {};
  bool? lastGuessCorrect;
  static const int winningScore = 10; // (still here if your logic uses it somewhere)
  int roundsPlayed = 0;

  @override
  void initState() {
    super.initState();

    // Players from Logicservice (as in your original)
    setState(() {
      players = Logicservice().players;
    });

    Logicservice().uploadPlayList();

    _controller = GifController(vsync: this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Select a random GIF
    _currentGif = _getRandomGif();

    // Initialize first gradient
    _currentGradient = _pickNextGradient();

    // Initialize player scores
    for (final player in players) {
      playerScores[player] = 0;
    }

    // Start game immediately after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await startGame();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // NOTE: All your game logic methods are still in:
  // part 'game/game_page_logic.dart';
  // e.g. startGame(), handleGuess(), handleGuessResult(), handleSkip(), _getWinners(), _getRandomGif(), etc.

  @override
  Widget build(BuildContext context) {
    Widget stateWidget;

    switch (currentState) {
      case 0: // Initial state
        stateWidget = Consumer<Logicservice>(
          builder: (context, logic, child) {
            final playlistName = (logic.playlist?.name == null)
                ? "None selected"
                : logic.playlist!.name!.substring(
                    0,
                    min(20, logic.playlist!.name!.length),
                  );

            return StartStateView(
              playlistImageUrl: logic.playlist?.imageUrl,
              playlistName: playlistName,
              onStart: () async => await startGame(),
              onBack: () => Navigator.of(context).pop(),
            );
          },
        );
        break;

      case 3: // Countdown state
        stateWidget = CountdownStateView(countdown: countdown);
        break;

      case 1: // Guessing state
        stateWidget = GuessingStateView(
          roundText: "${roundsPlayed + 1}/${widget.rounds}",
          gifPath: _currentGif,
          gifController: _controller,
          players: players,
          onPlayerSelected: (p) => handleGuess(p),
          onSkip: () => handleSkip(),
        );
        break;

      case 2: // Waiting for guess result
        stateWidget = WaitingForGuessResultView(
          guessingPlayer: guessingPlayer,
          countdown: countdown,
        );
        break;

      case 4: // Reveal song and choose correct/incorrect (or show result)
        stateWidget = RevealStateView(
          skippedRound: skippedRound,
          guessingPlayer: guessingPlayer,
          currentSong: currentSong,
          lastGuessCorrect: lastGuessCorrect,
          onGuessResult: (v) => handleGuessResult(v),
          players: players,
          playerScores: playerScores,
        );
        break;

      case 5: // Game over
        stateWidget = GameOverView(
          winners: _getWinners(),
          players: players,
          playerScores: playerScores,
          onBackToMenu: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const SetupPage()),
            );
          },
        );
        break;

      default:
        stateWidget = const Text("Unknown state");
    }

    return GameShell(
      gradient: _currentGradient,
      fadeAnimation: _fadeAnimation,
      child: stateWidget,
    );
  }
}
