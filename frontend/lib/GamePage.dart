library game_page;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gif/gif.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/services/SpotifyService.dart';
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
  String _currentGif = "assets/gifs/xz.gif";

  final List<LinearGradient> _gradientPalette = const [
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

  Map<String, int> playerScores = {};
  bool? lastGuessCorrect;
  static const int winningScore = 10;
  int roundsPlayed = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      players = Logicservice().players;
    });
    Logicservice().uploadPlayList();
    _controller = GifController(vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _currentGif = _getRandomGif();

    _currentGradient = _pickNextGradient();

    for (var player in players) {
      playerScores[player] = 0;
    }

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

  Widget _buildAnimatedCountdown(int count, {double fontSize = 120}) {
    return Text(
          "$count",
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        )
        .animate(key: ValueKey(count))
        .fadeIn(duration: 250.ms)
        .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1.0, 1.0),
          duration: 750.ms,
          curve: Curves.elasticOut,
        )
        .blur(
          begin: const Offset(10, 10),
          end: Offset.zero,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  @override
  Widget build(BuildContext context) {
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

    const double kDefaultPadding = 24.0;
    const double kLargePadding = 40.0;
    const double kSmallPadding = 16.0;
    const double kDefaultSpacing = 15.0;
    const double kSmallSpacing = 20.0;

    Widget buildScoreBoard({bool isGameOver = false}) {
      final highestScore = playerScores.isEmpty
          ? 0
          : playerScores.values.reduce(max);

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Text(
              "SCOREBOARD",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: AnimateList(
                interval: 100.ms,
                effects: [
                  FadeEffect(duration: 600.ms, curve: Curves.easeOut),
                  SlideEffect(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                ],
                children: players.map((player) {
                  final score = playerScores[player] ?? 0;
                  final isLeader = score == highestScore && score > 0;
                  final isWinner = isGameOver && isLeader;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (isWinner)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child:
                                    const Icon(
                                          Icons.emoji_events,
                                          color: Colors.amber,
                                          size: 20,
                                        )
                                        .animate(onPlay: (c) => c.repeat())
                                        .shimmer(
                                          duration: 2000.ms,
                                          color: Colors.white,
                                        )
                                        .scale(
                                          begin: const Offset(0.8, 0.8),
                                          end: const Offset(1.2, 1.2),
                                          duration: 1000.ms,
                                          curve: Curves.easeInOut,
                                          alignment: Alignment.center,
                                        )
                                        .then()
                                        .scale(
                                          begin: const Offset(1.2, 1.2),
                                          end: const Offset(0.8, 0.8),
                                          duration: 1000.ms,
                                          curve: Curves.easeInOut,
                                        ),
                              ),
                            Text(
                              player.toUpperCase(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isLeader
                                    ? FontWeight.w900
                                    : FontWeight.w500,
                                color: isLeader
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.8),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isLeader
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                "$score",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: isLeader ? Colors.black : Colors.white,
                                ),
                              ),
                            )
                            .animate(target: isLeader ? 1 : 0)
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.1, 1.1),
                              duration: 500.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scale(
                              begin: const Offset(1.1, 1.1),
                              end: const Offset(1, 1),
                              duration: 500.ms,
                              curve: Curves.easeInOut,
                            ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    }

    Widget stateWidget;

    switch (currentState) {
      case 0:
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
          child: _buildAnimatedCountdown(countdown ?? 3, fontSize: 120),
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
                    childAspectRatio: 2, // wider buttons, less height
                    children: players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;

                      return ElevatedButton(
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
                      );
                    }).toList(),
                  ),
                  SizedBox(height: kDefaultSpacing),
                  Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => handleSkip(),
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
                        "Keine Ahnung",
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
              _buildAnimatedCountdown(countdown ?? 5, fontSize: 100),
            ],
          ),
        );
        break;
      case 4: // Show song title and guess result
        stateWidget = Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: AnimateList(
              interval: 100.ms,
              effects: [
                FadeEffect(duration: 500.ms, curve: Curves.easeOut),
                SlideEffect(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                  duration: 500.ms,
                  curve: Curves.easeOutQuad,
                ),
              ],
              children: [
                if (!skippedRound && guessingPlayer != null)
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
                if (!skippedRound && guessingPlayer != null)
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
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
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
                            currentSong?.artists.join(", ") ?? "FEHLER",
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
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white70)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        currentSong?.release_date?.split('-').first ??
                            "NO DATE",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white70)),
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
                      if (!skippedRound) ...[
                        ElevatedButton(
                          onPressed: () => handleGuessResult(true, false),
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
                          onPressed: () => handleGuessResult(false, false),
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
                      ] else ...[
                        ElevatedButton(
                          onPressed: () => handleGuessResult(false, true),
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
                            "WEITER",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: kDefaultSpacing),
                      buildScoreBoard(),
                    ],
                  )
                else
                  buildScoreBoard(),
              ],
            ),
          ),
        );
        break;
      case 5: // Game over state
        stateWidget = Container(
          padding: EdgeInsets.symmetric(vertical: kLargePadding),
          margin: EdgeInsets.zero,
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
}
