import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GameSettingsPage extends StatefulWidget {
  const GameSettingsPage({super.key});

  @override
  State<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends State<GameSettingsPage> {
  bool _soundEnabled = true;
  bool _fastMode = false;

  void _showRoundsDialog(BuildContext context, Logicservice logic) {
    final maxRounds = logic.tracks.length;
    final controller = TextEditingController(text: logic.rounds.toString());
    String? errorText;

    showCupertinoDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return CupertinoAlertDialog(
              title: const Text('Runden Anzahl'),
              content: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 40,
                      child: CupertinoTextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: false,
                          decimal: false,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        placeholder: maxRounds > 0 ? '1 bis $maxRounds' : '1+',
                        textAlign: TextAlign.center,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {},
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        errorText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: CupertinoColors.systemRed,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                CupertinoDialogAction(
                  child: const Text('Abbrechen'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Bestätigen'),
                  onPressed: () {
                    final text = controller.text.trim();
                    final value = int.tryParse(text);
                    if (value == null || value < 1) {
                      setState(() {
                        errorText = 'Bitte eine gültige Zahl (≥ 1) eingeben.';
                      });
                      return;
                    }
                    if (maxRounds > 0 && value > maxRounds) {
                      setState(() {
                        errorText = 'Maximal $maxRounds Runden möglich.';
                      });
                      return;
                    }
                    logic.setRounds(value);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingItem({
    required String icon,
    required String title,
    String? value,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (value != null)
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black54),
              ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        final int maxRounds = logic.tracks.length;
        final effectiveRounds = (maxRounds > 0 && logic.rounds > maxRounds)
            ? maxRounds
            : logic.rounds;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            foregroundColor: Colors.white,
            title: const Text(
              'Spieleinstellungen',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF9A7BFF),
                  Color(0xFF7A5EFF),
                  Color(0xFF5A3EFF),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildSettingItem(
                            icon: "🎮",
                            title: "Runden Anzahl",
                            value: "$effectiveRounds",
                            onTap: () => _showRoundsDialog(context, logic),
                          ),
                          const Divider(height: 1, thickness: 0.5),
                          _buildSettingItem(
                            icon: "📉",
                            title: "Punktabzug",
                            trailing: CupertinoSwitch(
                              value: logic.decreasePoints,
                              onChanged: (value) {
                                logic.setDecreasePoints(value);
                              },
                              activeColor: const Color(0xFF7A5EFF),
                            ),
                          ),
                        ]
                            .animate(interval: 50.ms)
                            .fade(duration: 400.ms)
                            .slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
                      ),
                    )
                        .animate()
                        .fade(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          curve: Curves.easeOutBack,
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
