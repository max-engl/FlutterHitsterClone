import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:marquee/marquee.dart';
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
                    )
                    .animate()
                    .fade(duration: 800.ms)
                    .slideY(begin: -0.2, end: 0, curve: Curves.easeOutBack)
                    .shimmer(delay: 1500.ms, duration: 1500.ms),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: Marquee(
                    text: 'Musik - Wissen - Spaß - ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.1,
                    ),
                    scrollAxis: Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    velocity: 50.0,

                    startPadding: 10.0,

                    fadingEdgeEndFraction: 0.5,
                    fadingEdgeStartFraction: 0.5,
                  ),
                ).animate().fade(delay: 400.ms, duration: 600.ms),
                const Spacer(),

                Container(
                      clipBehavior: Clip.hardEdge,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 26,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
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
                    )
                    .animate()
                    .fade(delay: 600.ms, duration: 600.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      curve: Curves.easeOut,
                    ),

                const Spacer(),

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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Center(child: Text('Weiter')),
                            Positioned(
                              right: 12,
                              child:
                                  Container(
                                        child: Icon(
                                          Icons.arrow_forward,
                                          size: 25,
                                        ),
                                      )
                                      .animate(
                                        delay: 200.ms,
                                        onPlay: (controller) =>
                                            controller.repeat(),
                                      )
                                      .shake(delay: 500.ms),
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fade(delay: 800.ms, duration: 600.ms)
                    .slideY(begin: 1, end: 0, curve: Curves.easeOutBack)
                    .shimmer(delay: 1500.ms, duration: 1500.ms),

                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
