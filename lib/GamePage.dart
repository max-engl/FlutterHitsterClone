library game_page;

import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/SpotifyService.dart';
import 'package:hitsterclone/services/AppleMusicService.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:provider/provider.dart';
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
  static const int winningScore = 10;
  int roundsPlayed = 0;

  // loadJsonFromAssets moved to extension

  @override
  void initState() {
    super.initState();
    setState(() {
      players = Logicservice().players;
    });
    _controller = GifController(vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
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
    for (var player in players) {
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

  // _triggerAnimation moved to extension

  // Check if any player has reached the winning score
  // Game over check moved to extension (rounds-based)

  // Get the winner(s) of the game
  // _getWinners moved to extension

  // startGame moved to extension

  // handleGuess moved to extension

  // New method to handle user's selection of correct/incorrect (moved to extension)

  @override
  Widget build(BuildContext context) {
    // Define consistent text styles
    final TextStyle headingStyle = TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      letterSpacing: 3.0,
      color: Colors.white,
    );

    final TextStyle subheadingStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.0,
      color: Colors.white,
    );

    final TextStyle buttonTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.0,
      color: Colors.white,
    );

    final TextStyle countdownStyle = TextStyle(
      fontSize: 120,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    );

    final TextStyle scoreStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.0,
      color: Colors.white,
    );

    // Define consistent spacing
    const double kDefaultPadding = 24.0;
    const double kLargePadding = 40.0;
    const double kSmallPadding = 16.0;
    const double kDefaultSpacing = 15.0;
    const double kLargeSpacing = 50.0;
    const double kSmallSpacing = 20.0;

    // Create a reusable widget for displaying scores
    // Build a scoreboard widget to display player scores
    Widget buildScoreBoard({bool isGameOver = false}) {
      final highestScore = playerScores.values.reduce(max);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
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
        child: Padding(
          padding: EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Punktestand:",
                style: scoreStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: kSmallSpacing),
              ...players.map((player) {
                final isWinner =
                    isGameOver && playerScores[player] == highestScore;
                return Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        player.toUpperCase(),
                        style: scoreStyle.copyWith(
                          fontWeight: isWinner
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "${playerScores[player]}",
                        style: scoreStyle.copyWith(
                          fontWeight: isWinner
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      );
    }

    Widget stateWidget;

    switch (currentState) {
      case 0: // Initial state
        stateWidget = Column(
          children: [
            Consumer<Logicservice>(
              builder: (context, logic, child) {
                return Column(
                  children: [
                    if (logic.playlist?.imageUrl != null)
                      Image.network(
                        logic.playlist!.imageUrl!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      logic.playlist?.name?.substring(
                            0,
                            min(20, logic.playlist!.name!.length),
                          ) ??
                          'None selected',
                      style: subheadingStyle.copyWith(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              },
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: kLargePadding,
                vertical: kDefaultPadding,
              ),
              child: ElevatedButton(
                onPressed: () async => await startGame(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: Size(double.infinity, 56),
                ),
                child: Text(
                  "START GAME",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: kLargePadding,
                vertical: 0,
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  "BACK",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        );
        break;
      case 3: // Countdown state
        stateWidget = Container(
          padding: EdgeInsets.all(kLargePadding),
          margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Text("$countdown", style: countdownStyle),
              );
            },
          ),
        );
        break;
      case 1: // Guessing state
        stateWidget = Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                children: [
                  Text(
                    "Denkt nach!",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                    ),
                  ),

                  Text(
                    (roundsPlayed + 1).toString() +
                        "/" +
                        widget.rounds.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: kDefaultSpacing),
                  Container(
                    width: 200,
                    height: 200,
                    child: Gif(
                      image: AssetImage(_currentGif),
                      controller:
                          _controller, // if duration and fps is null, original gif fps will be used.
                      //fps: 30,
                      //duration: const Duration(seconds: 3),
                      autostart: Autostart.no,
                      placeholder: (context) => const Text('Loading...'),
                      onFetchCompleted: () {
                        _controller.reset();
                        _controller
                            .repeat(); // Changed from forward() to repeat() to make the gif loop
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    "Wer weiß es? ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 5),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: kSmallSpacing,
                    crossAxisSpacing: kSmallSpacing,
                    childAspectRatio: 1.7, // wider buttons, less height
                    children: players
                        .map(
                          (player) => ElevatedButton(
                            onPressed: () => handleGuess(player),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              elevation: 1,
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              player.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        );
        break;
      case 2: // Waiting for guess result
        stateWidget = Container(
          padding: EdgeInsets.all(kLargePadding),
          margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (guessingPlayer != null)
                Text(
                  "${guessingPlayer!.toUpperCase()} will raten!",
                  style: subheadingStyle.copyWith(fontSize: 30),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: kSmallSpacing),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.5, end: 1.0),
                duration: Duration(milliseconds: 800),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Text(
                      "$countdown",
                      style: countdownStyle.copyWith(fontSize: 100),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
          ),
        );
        break;
      case 4: // Show song title and guess result
        stateWidget = Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              if (guessingPlayer != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${guessingPlayer!}",
                      style: subheadingStyle.copyWith(
                        fontSize: 50,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              Text(
                " hat geraten:",
                style: subheadingStyle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),

              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (currentSong?.albumImageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          currentSong!.albumImageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentSong?.name ?? "FEHLER",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),

                        const SizedBox(height: 4),
                        Text(
                          currentSong?.artists.first ?? "FEHLER",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: kDefaultSpacing),
              if (lastGuessCorrect != null && guessingPlayer != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: kSmallPadding,
                    horizontal: kDefaultPadding,
                  ),
                  decoration: const BoxDecoration(color: Colors.transparent),
                  child: Text(
                    lastGuessCorrect!
                        ? "${guessingPlayer!.toUpperCase()} GUESSED CORRECTLY!"
                        : "${guessingPlayer!.toUpperCase()} GUESSED INCORRECTLY",
                    style: subheadingStyle.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: kDefaultSpacing),
              if (lastGuessCorrect == null)
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => handleGuessResult(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text(
                        "RICHTIG GERATEN",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: kDefaultSpacing),
                    ElevatedButton(
                      onPressed: () => handleGuessResult(false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: const Text(
                        "LEIDER FALSCH",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: kDefaultSpacing),
                    buildScoreBoard(),
                  ],
                )
              else
                buildScoreBoard(),
            ],
          ),
        );

        break;
      case 5: // Game over state
        stateWidget = Container(
          padding: EdgeInsets.all(kLargePadding),
          margin: EdgeInsets.symmetric(horizontal: kDefaultPadding),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: Colors.transparent, width: 0),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Spiel vorbei!",
                    style: headingStyle.copyWith(fontSize: 200),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                  ),
                ),
                SizedBox(height: kDefaultSpacing),
                if (_getWinners().length == 1)
                  Text(
                    "${_getWinners().first.toUpperCase()} GEWINNT!",
                    style: subheadingStyle,
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    "Unendschieden!",
                    style: subheadingStyle,
                    textAlign: TextAlign.center,
                  ),
                buildScoreBoard(isGameOver: true),
                SizedBox(height: kDefaultSpacing),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const SetupPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: const Text(
                      "Zurück zum Menü",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        break;
      default:
        stateWidget = Text("Unknown state");
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF5A3EFF),
      body: AnimatedContainer(
        constraints: const BoxConstraints.expand(),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(gradient: _currentGradient),
        child: SafeArea(
          child: SingleChildScrollView(
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

                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: stateWidget,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _playerRow(String name, int points) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              "$points",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, color: Colors.black38, size: 22),
          ],
        ),
      ),
    );
  }
}
