part of game_page;

extension _GamePageLogic on _GamePageState {
  // Get a random GIF from the list
  String _getRandomGif() {
    final random = Random();
    return _gifList[random.nextInt(_gifList.length)];
  }

  Future<void> loadJsonFromAssets() async {}

  void _triggerAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  // Check if game is over based on number of rounds played
  bool _isGameOver() {
    if (roundsPlayed >= widget.rounds) {
      Logicservice().resetTracksToPlay();
    }
    return roundsPlayed >= widget.rounds;
  }

  // Get the winner(s) of the game
  List<String> _getWinners() {
    int highestScore = playerScores.values.reduce((a, b) => a > b ? a : b);
    return playerScores.entries
        .where((entry) => entry.value == highestScore)
        .map((entry) => entry.key)
        .toList();
  }

  Future<void> startGame() async {
    // Select a new random GIF
    setState(() {
      _currentGif = _getRandomGif();
      countdown = 3;
      currentState = 3; // New state for countdown
      lastGuessCorrect = null; // Reset last guess result
    });
    _triggerAnimation();
    if (Logicservice().musicService == 'spotify') {
      SpotifyService().pauseSong();
    } else {
      AppleMusicService().pauseSong();
      print('AM debug: paused before countdown, tracks=${Logicservice().tracks.length}, yetToPlay=${Logicservice().trackYetToPlay.length}');
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      setState(() {
        countdown = countdown! - 1;
        if (countdown! <= 0) {
          timer.cancel();
          currentState = 1; // Switch to guessing state
          _triggerAnimation();
        }
      });

      if (countdown! <= 0) {
        if (Logicservice().musicService == 'spotify') {
          final songInfo = await SpotifyService().playRandomSong();
          if (songInfo != null) {
            setState(() {
              currentSong = songInfo;
            });
          } else {
            setState(() {
              currentSong = null;
            });
          }
        } else {
          print('AM debug: attempting to play random song from ${Logicservice().trackYetToPlay.length} pending tracks');
          final songInfo = await AppleMusicService().playRandomSong();
          if (songInfo != null) {
            print('AM debug: now playing id=${songInfo.id} name=${songInfo.name} uri=${songInfo.uri}');
            setState(() {
              currentSong = songInfo;
            });
          } else {
            print('AM debug: playRandomSong returned null');
            setState(() {
              currentSong = null; // Handle no-track case
            });
          }
        }
      }
    });
  }

  void handleGuess(String player) {
    setState(() {
      guessingPlayer = player;
      currentState = 2;
      countdown = 5; // Set 5 second countdown for guess result
    });
    _triggerAnimation();
    if (Logicservice().musicService == 'spotify') {
      SpotifyService().pauseSong();
    } else {
      AppleMusicService().pauseSong();
      print('AM debug: paused for guess');
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        countdown = countdown! - 1;
        if (countdown! <= 0) {
          timer.cancel();

          // Instead of determining correctness here, we'll show buttons for user to select
          setState(() {
            // Reveal the song title and show correct/incorrect buttons
            currentState = 4; // State to show the song title and guess result
          });

          _triggerAnimation();
          if (currentSong != null) {
            if (Logicservice().musicService == 'spotify') {
              SpotifyService().resumeSong();
            } else {
              AppleMusicService().resumeSong();
              print('AM debug: resumed after reveal, current=${currentSong?.name}');
            }
          }
        }
      });
    });
  }

  // New method to handle user's selection of correct/incorrect
  void handleGuessResult(bool isCorrect) {
    // Update player score if correct
    if (isCorrect && guessingPlayer != null) {
      playerScores[guessingPlayer!] = (playerScores[guessingPlayer!] ?? 0) + 1;
    }

    setState(() {
      lastGuessCorrect = isCorrect;

      // Start next song automatically
      // Increment rounds after each guess resolution
      roundsPlayed += 1;

      if (_isGameOver()) {
        currentState = 5; // Game over state
      } else {
        // Pick a new gradient for the next round
        _currentGradient = _pickNextGradient();
        // Start next song
        startGame();
      }
    });
  }
}
