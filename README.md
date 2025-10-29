# HIPSTER 🎵

A fast-paced music trivia game powered by Spotify Premium. Challenge friends to guess song titles and artists in quick rounds with seamless Spotify integration.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Spotify](https://img.shields.io/badge/Spotify-1ED760?style=for-the-badge&logo=spotify&logoColor=white)

## 🛠️ Technology Stack

### Core Framework
- **Flutter 3.8.1+** - Cross-platform UI framework
- **Dart** - Programming language
- **Provider** - State management solution

### Spotify Integration
- **Spotify Web API** - Music metadata, playlists, and search functionality
- **Spotify SDK** (`spotify_sdk: ^3.0.2`) - Native playback control and device management
- **Spotify Connect API** - Device selection and playback transfer
- **OAuth 2.0** - Secure authentication flow

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
- **iOS** - Native iOS app with Spotify SDK integration
- **Android** - Native Android app with Spotify SDK integration
- **Web** - Limited web support (development/testing only)
- **macOS/Windows/Linux** - Desktop support available

### Security & Authentication
- **PKCE (Proof Key for Code Exchange)** - Secure OAuth flow
- **Crypto** (`crypto: ^3.0.6`) - Cryptographic operations for auth
- **Secure token storage** - Encrypted credential management

## 🎮 Features

- **Spotify Integration**: Connect your Spotify Premium account for authentic music playback
- **Device Selection**: Choose any Spotify-compatible device for audio output
- **Flexible Music Sources**: Play from playlists or search for specific artists
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
- **Spotify Premium Account** (required for playback)
- **iOS Simulator/Device** or **Android Emulator/Device**

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

3. **Configure Spotify API**
   - Create a Spotify app at [Spotify Developer Dashboard](https://developer.spotify.com/dashboard)
   - Add your app's redirect URI to the Spotify app settings
   - Update the Spotify configuration in your app (check `WebApiService.dart`)

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
- Open `ios/Runner.xcworkspace` in Xcode if you need to configure signing

#### Android
- Ensure you have Android Studio installed
- Configure your Android SDK and emulator

## 🎯 How to Play

1. **First Launch**: The app will show a welcome screen explaining Spotify Premium requirements
2. **Setup**:
   - Connect to Spotify and authorize the app
   - Select a playback device (speakers, phone, etc.)
   - Add players (minimum 2 required)
   - Choose a playlist or search for an artist
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
├── SearchPlaylistPage.dart  # Playlist search
├── ArtistSelectionPage.dart # Artist search
├── PlaylistScreen.dart      # Playlist details
├── GamePage.dart           # Main game interface
├── services/
│   ├── LogicService.dart   # Game state management
│   ├── SpotifyService.dart # Spotify playback control
│   └── WebApiService.dart  # Spotify Web API integration
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
3. Add these redirect URIs:
   - `your-app-scheme://callback` (for mobile)
   - `http://localhost:8888/callback` (for development)
4. Note your Client ID and Client Secret
5. Update the configuration in `lib/services/WebApiService.dart`

### Environment Variables

Create a `.env` file in the root directory (optional):
```env
SPOTIFY_CLIENT_ID=your_client_id_here
SPOTIFY_CLIENT_SECRET=your_client_secret_here
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
   - Ensure your Spotify app has the correct redirect URIs
   - Check that you're using a Spotify Premium account
   - Verify your Client ID is correct

2. **No Audio Playback**
   - Ensure you have an active Spotify device
   - Check that the selected device supports Spotify Connect
   - Try refreshing the device list

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
- Powered by [Spotify Web API](https://developer.spotify.com/documentation/web-api/)
- Inspired by music trivia games and party entertainment

---

**Note**: This app requires a Spotify Premium subscription for full functionality. The app uses Spotify's Web API and SDK for music playback and cannot function without proper authentication and premium access.