# HIPSTER 🎵

A fast-paced music trivia game for Apple Music. Challenge friends to guess song titles and artists in quick rounds with native Apple Music playback.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Apple Music](https://img.shields.io/badge/Apple%20Music-FA243C?style=for-the-badge&logo=applemusic&logoColor=white)

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.8.1+** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management solution
- **Shared Preferences** - Local data persistence

### Apple Music Integration
- **MusicKit (native bridge)** - Authorization and playback via iOS native APIs
- **Swift Player Manager** (`ios/Runner/MusicPlayerManager.swift`) - Plays songs using Apple Music with catalog→library fallback
- **Flutter platform channel** (`lib/MusicKit.dart`) - Bridge between Flutter and native iOS playback

### UI & Animation Libraries
- **Cupertino Icons** - iOS-style icons
- **Font Awesome Flutter** (`font_awesome_flutter: ^10.11.0`) - Icon library
- **Wave** (`wave: ^0.2.2`) - Wave animations
- **Confetti** (`confetti: ^0.8.0`) - Celebration effects
- **GIF Support** (`gif: ^2.3.0`) - Animated GIF rendering

### UI & Animation Libraries
- **Cupertino Icons** - iOS-style icons
- **Font Awesome Flutter** (`font_awesome_flutter: ^10.11.0`) - Icon library
- **Wave** (`wave: ^0.2.2`) - Wave animations
- **Confetti** (`confetti: ^0.8.0`) - Celebration effects
- **GIF Support** (`gif: ^2.3.0`) - Animated GIF rendering

### Development & Build Tools
- **Flutter Launcher Icons** (`flutter_launcher_icons: ^0.14.4`) - App icon generation
- **Change App Package Name** (`change_app_package_name: ^1.5.0`) - Package management
- **Rename** (`rename: ^3.1.0`) - Project renaming utilities
- **Flutter Lints** - Code quality and style enforcement

### Platform Support
- **iOS** - Primary platform with Apple Music playback via native bridge
- **Android/Web/Desktop** - UI builds may run for development, but Apple Music playback is iOS-only

### Security & Authentication
- **Apple Music authorization** - User grants Apple Music access via MusicKit
- **Secure local storage** - Preferences and lightweight state

## 🎮 Features

- **Apple Music Playback**: Native iOS playback with MusicKit
- **Playlist Sources**: Choose from your Apple Music library playlists or public catalog playlists
- **Multiplayer Support**: Add multiple players and track scores in real-time
- **Customizable Rounds**: Set the number of rounds to fit your session
- **Clean UI**: Modern, responsive interface with smooth animations
- **Persistent Settings**: Your preferences and players are saved between sessions
- **Confirmation Dialogs**: Prevent accidental selections with user-friendly prompts

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **An iOS device or simulator**
- **Apple Music subscription** on the device

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd hitsterclone
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Authorize Apple Music**
   - On first launch, the app will request Apple Music access
   - Grant access to enable playback and library access

4. **Run the app**
   ```bash
   # For iOS
   flutter run -d ios
   
   # For Android
   flutter run -d android
   
   # For Web (development only)
   flutter run -d web
   ```

### Platform-Specific Setup

#### iOS
- Ensure you have Xcode installed
- Open `ios/Runner.xcworkspace` in Xcode for signing if needed

## 🎯 How to Play

1. **First Launch**: The app will show a welcome screen explaining Spotify Premium requirements
2. **Setup**:
   - Authorize Apple Music when prompted
   - Add players (minimum 2 recommended)
   - Choose a playlist (library or public catalog)
   - Set the number of rounds
3. **Game Flow**:
   - Songs play automatically from your selected source
   - Players press their button when they know the song
   - First player to press gets to guess
   - Mark guesses as correct/incorrect
   - Scores update automatically
   - Game ends after all rounds, showing the winner

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── StartUpPage.dart         # Welcome/onboarding screen
├── SetupPage.dart           # Main game configuration
├── AddPlayersPage.dart      # Player management
├── PlaylistSourcePage.dart  # Music source selection
├── AppleLibraryPlaylistsPage.dart # Library playlists
├── AppleCatalogPlaylistsPage.dart # Public catalog playlists
├── PlaylistScreen.dart      # Playlist details
├── GamePage.dart           # Main game interface
├── services/
│   ├── LogicService.dart   # Game state management
│   ├── AppleMusicService.dart # Apple Music playlist/track helpers
│   └── WebApiService.dart  # Shared models (Playlist/Track)
├── theme/
│   └── app_theme.dart      # App styling and constants
├── game/
│   └── game_page_logic.dart # Game logic utilities
└── widgets/                # Reusable UI components
```

## 🔧 Configuration

### Apple Music Setup

Apple Music authorization occurs at runtime on iOS devices. Ensure the device has an active Apple Music subscription and is signed in. Playback uses native iOS MusicKit via a Flutter platform channel.

### Environment Variables

No external API credentials are required for Apple Music authorization. Configuration is handled by the OS.

## 🛠️ Development

### Key Dependencies

- `flutter`: UI framework
- `provider`: State management
- `shared_preferences`: Local data persistence
- `font_awesome_flutter`: Icons
- `confetti`: Celebration animations
- `gif`: Animated GIF rendering

### Building for Release

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

### Code Style

This project follows standard Dart/Flutter conventions:
- Use `dart format` to format code
- Run `flutter analyze` to check for issues
- Follow the [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines

## 🐛 Troubleshooting

### Common Issues

1. **Apple Music Authorization Fails**
   - Ensure the device is signed into Apple Music and has an active subscription
   - Reopen the app and grant access when prompted

2. **No Audio Playback**
   - Apple Music may require network access or subscription validation
   - Try playing a song in the Music app, then return to HIPSTER

3. **App Crashes on Startup**
   - Run `flutter clean && flutter pub get`
   - Check that all dependencies are properly installed
   - Ensure you're using the correct Flutter version

### Debug Mode

Run the app in debug mode for detailed error messages:
```bash
flutter run --debug
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

If you encounter any issues or have questions:
- Check the [Issues](../../issues) page
- Create a new issue with detailed information about your problem

## 🎵 Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Powered by Apple Music via iOS MusicKit
- Inspired by music trivia games and party entertainment

---

**Note**: This app requires an Apple Music subscription on iOS for playback. Authorization occurs via MusicKit.
