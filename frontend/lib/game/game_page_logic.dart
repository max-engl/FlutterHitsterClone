part of game_page;

extension _GamePageLogic on _GamePageState {
  String _getRandomGif() {
    final random = Random();
    return _gifList[random.nextInt(_gifList.length)];
  }

  Future<void> loadJsonFromAssets() async {}

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  bool _isGameOver() {
    if (roundsPlayed >= widget.rounds) {
      Logicservice().resetTracksToPlay();
    }
    return roundsPlayed >= widget.rounds;
  }

  List<String> _getWinners() {
    int highestScore = playerScores.values.reduce((a, b) => a > b ? a : b);
    return playerScores.entries
        .where((entry) => entry.value == highestScore)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> startGame() async {
    setState(() {
      _currentGif = _getRandomGif();
      countdown = 3;
      currentState = 3;
      lastGuessCorrect = null;
      skippedRound = false;
    });
    _triggerAnimation();
    SpotifyService().pauseSong();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {
        countdown = countdown! - 1;
        if (countdown! <= 0) {
          timer.cancel();
          currentState = 1;
          _triggerAnimation();
        }
      });

      if (countdown! <= 0) {
        Track? songInfo = await SpotifyService().playRandomSong();
        if (songInfo != null) {
          setState(() {
            currentSong = songInfo;
          });
        } else {
          setState(() {
            currentSong = null;
          });
        }
      }
    });
  }

  void handleGuess(String player) {
    setState(() {
      guessingPlayer = player;
      currentState = 2;
      countdown = 5;
    });
    _triggerAnimation();
    SpotifyService().pauseSong();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdown = countdown! - 1;
        if (countdown! <= 0) {
          timer.cancel();

          setState(() {
            currentState = 4;
          });

          _triggerAnimation();
          if (currentSong != null) {
            SpotifyService().resumeSong();
          }
        }
      });
    });
  }

  void handleSkip() {
    setState(() {
      skippedRound = true;
      guessingPlayer = null;
      currentState = 4;
    });
    _triggerAnimation();
  }

  void handleGuessResult(bool isCorrect, bool isNobody) {
    if (isCorrect && guessingPlayer != null) {
      playerScores[guessingPlayer!] = (playerScores[guessingPlayer!] ?? 0) + 1;
    }
    if (!isCorrect && !isNobody && Logicservice().decreasePoints) {
      playerScores[guessingPlayer!] = (playerScores[guessingPlayer!] ?? 0) - 1;
    }

    setState(() {
      lastGuessCorrect = isCorrect;

      roundsPlayed += 1;

      if (_isGameOver()) {
        currentState = 5;
      } else {
        _currentGradient = _pickNextGradient();
        startGame();
      }
    });
  }
}
