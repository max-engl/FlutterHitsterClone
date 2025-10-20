import 'package:flutter/material.dart';
import 'package:hitsterclone/BeforeGamePage.dart';
import 'package:hitsterclone/services/WebApiService.dart';
import 'package:hitsterclone/theme/app_theme.dart';

class SpotifyAuthPage extends StatefulWidget {
  const SpotifyAuthPage({super.key});

  @override
  State<SpotifyAuthPage> createState() => _SpotifyAuthPageState();
}

class _SpotifyAuthPageState extends State<SpotifyAuthPage> {
  bool _authorizing = false;
  String? _error;

  Future<void> _authorize() async {
    setState(() {
      _authorizing = true;
      _error = null;
    });
    try {
      final token = await WebApiService().fetchSpotifyAccessToken();
      if (token == null || token.isEmpty) {
        setState(() {
          _error = 'Authorization failed. Please try again.';
          _authorizing = false;
        });
        return;
      }
      WebApiService().setToken(token);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BeforeGamePage()),
      );
    } catch (e) {
      setState(() {
        _error = 'Authorization error: $e';
        _authorizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPOTIFY AUTH', style: TextStyle(letterSpacing: 2.0)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.kDefaultPadding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'WHY SPOTIFY AUTHORIZATION?',
                    style: AppTheme.subheadingStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.kSmallSpacing),
                  const Text(
                    'This game plays music via your Spotify account. We need your permission to control playback on your device during rounds.\n\n'
                    'Requested permissions: play/pause/skip and read playback state. We do not modify or access your playlists beyond reading tracks for the selected game playlist.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.kDefaultSpacing),
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.kSmallPadding),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                        color: Colors.white,
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppTheme.kDefaultSpacing),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authorizing ? null : _authorize,
                      style: _authorizing
                          ? AppTheme.primaryButtonStyle.copyWith(
                              backgroundColor:
                                  const MaterialStatePropertyAll(Colors.grey),
                            )
                          : AppTheme.primaryButtonStyle,
                      child: _authorizing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('AUTHORIZING...',
                                    style: AppTheme.buttonTextStyle),
                              ],
                            )
                          : Text('AUTHORIZE WITH SPOTIFY',
                              style: AppTheme.buttonTextStyle),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}