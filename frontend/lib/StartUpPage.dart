import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';

class StartUpPage extends StatelessWidget {
  const StartUpPage({super.key});

  void _showPremiumConfirmDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Spotify Premium'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Hast du Spotify Premium?\nDu benötigst es, um die App zu nutzen.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Nein'),
            onPressed: () {
              Navigator.of(ctx).pop();
              showCupertinoDialog(
                context: context,
                builder: (ctx2) => const CupertinoAlertDialog(
                  title: Text('Premium benötigt'),
                  content: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Um fortzufahren wird Spotify Premium benötigt.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Ja'),
            onPressed: () {
              Navigator.of(ctx).pop();
              // Mark startup as seen so future launches skip this page
              context.read<Logicservice>().markStartupSeen();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SetupPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFD57A), Color(0xFFFF9E5A), Color(0xFFFF6B3E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // App name centered and bold
                const Text(
                  'HIPSTER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'MUSIK. WISSEN. SPASS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.1,
                  ),
                ),

                const Spacer(),

                // Card-like info section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 1),
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Willkommen!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Um fortzufahren benötigst du Spotify Premium.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Bitte bestätige, dass du Spotify Premium besitzt.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPremiumConfirmDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    child: const Text('Weiter'),
                  ),
                ),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
