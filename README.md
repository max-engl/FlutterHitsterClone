# HIPSTER 🎵

A fast-paced music trivia game with native Apple Music playback and Spotify Web API for search/metadata. Challenge friends to guess song titles and artists in quick rounds.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Apple Music](https://img.shields.io/badge/Apple%20Music-FA243C?style=for-the-badge&logo=applemusic&logoColor=white)

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.8.1+** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management solution

### Apple Music & Spotify Integration
- **Apple Music Playback (iOS)** - Native playback via MusicKit
- **Spotify Web API** - Playlist/artist search and metadata only (no Spotify playback)
- **OAuth (PKCE)** - Secure Spotify auth via `flutter_web_auth_2`

### Key APIs & Services
- **Spotify Web API Endpoints**:
  - `/v1/me/playlists` - User playlists
  - `/v1/search` - Artist and playlist search
  - `/v1/artists/{id}/top-tracks` - Artist's popular tracks
  - `/v1/me/player/devices` - Available playback devices
  - `/v1/me/player` - Playback control and transfer
- **Flutter Web Auth 2** (`flutter_web_auth_2: ^4.1.0`) - OAuth authentication
- **Shared Preferences** - Local data persistence

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
- **iOS** - Primary platform with Apple Music playback
- **Android/Web/Desktop** - UI builds for development; playback is iOS-only

### Security & Authentication
- **Apple Music authorization** - iOS MusicKit prompts user for access
- **Spotify OAuth (PKCE)** - Uses `.env` to store client id and config

## 🎮 Features

- **Apple Music Playback**: Native iOS playback
- **Flexible Sources**: Library playlists, public playlists, or artists
- **Artist Multi-Select**: Select multiple artists and fetch all songs with a progress dialog
- **Multiplayer Support**: Add multiple players and track scores in real-time
- **Customizable Rounds**: Set the number of rounds
- **Clean UI**: Modern, responsive interface with smooth animations
- **Persistent Settings**: Preferences and players persisted
- **Confirmation Dialogs**: To prevent accidental selections

## 📱 Screenshots

*Add screenshots of your app here*

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (included with Flutter)
- **An iOS device or simulator** (for Apple Music playback)
- **Apple Music subscription** on the device
- **Spotify Developer account** (for metadata/search)

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

3. **Create Spotify App**
   - Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Create an app and add redirect URI: `hipsterclone://callback`
   - Copy your Client ID

4. **Create .env** (auto-ignored by Git)
   - In `hitsterclone/`, create `.env` using `.env.example` as a template:
   ```env
   SPOTIFY_CLIENT_ID=your_client_id
   SPOTIFY_REDIRECT_URI=hipsterclone://callback
   SPOTIFY_SCOPES=user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-top-read
   ```

5. **Install dependencies**
   ```bash
   flutter pub get
   ```

6. **Run the app**
   ```bash
   # iOS (playback supported)
   flutter run -d ios
   # Android/Web/Desktop (UI only)
   flutter run -d android
   ```

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
- URL scheme `hipsterclone` is already configured in `ios/Runner/Info.plist`
- Ensure device has an active Apple Music subscription and is signed in

#### Android
- Ensure you have Android Studio installed
- Configure your Android SDK and emulator

## 🎯 How to Play

1. **First Launch**: Confirm Apple Music subscription when prompted
2. **Setup**
   - Authorize Apple Music when prompted
   - Add players
   - Choose a source:
     - `Artist`: enable “Mehrere Artists?” for multi-select; tap “Fertig” to fetch all songs (with progress)
     - `Deine Playlists`: pick a library playlist
     - `Öffentliche Playlists`: search public playlists
   - Tap the selected summary card to preview all selected songs
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
├── SearchPlaylistPage.dart        # Public playlist search
├── ArtistSelectionPage.dart       # Artist search + multi-select
├── PlaylistScreen.dart            # Library playlists
├── SelectedSongsPage.dart         # Selected songs preview list
├── GamePage.dart           # Main game interface
├── services/
│   ├── LogicService.dart   # Game state management
│   ├── SpotifyService.dart       # (legacy) Spotify playback control
│   └── WebApiService.dart        # Spotify Web API integration (search/metadata)
├── theme/
│   └── app_theme.dart      # App styling and constants
├── game/
│   └── game_page_logic.dart # Game logic utilities
└── widgets/                # Reusable UI components
```

## 🔧 Configuration

### Spotify API Setup

1. Go to [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
2. Create a new app
3. Add redirect URI:
   - `hipsterclone://callback`
4. Note your Client ID and Client Secret
5. Update the configuration in `lib/services/WebApiService.dart`

### Environment Variables

Create `.env` in `hitsterclone/` based on `.env.example`:
```env
SPOTIFY_CLIENT_ID=your_client_id
SPOTIFY_REDIRECT_URI=hipsterclone://callback
SPOTIFY_SCOPES=user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-read-collaborative user-top-read
```

## 🛠️ Development

### Key Dependencies

- `flutter`: UI framework
- `spotify_sdk`: Native Spotify SDK integration
- `provider`: State management
- `shared_preferences`: Local data persistence
- `flutter_web_auth_2`: OAuth authentication
- `font_awesome_flutter`: Icons
- `confetti`: Celebration animations

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

1. **Spotify Authentication Fails**
   - Ensure `.env` contains `SPOTIFY_CLIENT_ID`
   - Confirm redirect URI in Spotify dashboard is `hipsterclone://callback`
   - Ensure iOS `Info.plist` includes URL scheme `hipsterclone`

2. **No Audio Playback (Apple Music)**
   - Ensure Apple Music subscription is active and user signed in
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
- Powered by Apple Music (playback) and [Spotify Web API](https://developer.spotify.com/documentation/web-api/) for search/metadata
- Inspired by music trivia games and party entertainment

---

**Note**: Playback requires an Apple Music subscription on iOS. Spotify Web API is used only for search/metadata; no Spotify playback.
