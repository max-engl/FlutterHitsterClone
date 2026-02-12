import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddPlayersPage extends StatefulWidget {
  const AddPlayersPage({super.key});

  @override
  State<AddPlayersPage> createState() => _AddPlayersPageState();
}

class _AddPlayersPageState extends State<AddPlayersPage> {
  final List<String> _localPlayers = [];

  @override
  void initState() {
    super.initState();
    final existing = context.read<Logicservice>().players;
    _localPlayers.addAll(existing);
  }

  void _saveAndClose() {
    context.read<Logicservice>().setPlayers(_localPlayers);
    Navigator.pop(context);
  }

  void _syncPlayers() {
    context.read<Logicservice>().setPlayers(_localPlayers);
  }

  void _showAddPlayerDialog() {
    final controller = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Spieler hinzufügen"),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Name',
              autofocus: true,
              textInputAction: TextInputAction.done,
              maxLines: 1,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Hinzufügen"),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              setState(() => _localPlayers.add(name));
              _syncPlayers();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showEditPlayerDialog(int index) {
    final controller = TextEditingController(text: _localPlayers[index]);

    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text("Spieler bearbeiten"),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: 40,
            child: CupertinoTextField(
              controller: controller,
              placeholder: 'Name',
              autofocus: true,
              textInputAction: TextInputAction.done,
              maxLines: 1,
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text("Löschen", style: TextStyle(color: Colors.red)),
            onPressed: () {
              setState(() => _localPlayers.removeAt(index));
              _syncPlayers();
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: const Text("Abbrechen"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text("Speichern"),
            onPressed: () {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              setState(() => _localPlayers[index] = name);
              _syncPlayers();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Logicservice>(
      builder: (context, logic, _) {
        return WillPopScope(
          onWillPop: () async {
            _syncPlayers();
            return true;
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text(
                "Spieler",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Container(
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
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
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
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: _localPlayers.isEmpty
                                ? SizedBox(
                                        height: 100,
                                        child: Center(
                                          child: Text(
                                            'Keine Spieler hinzugefügt',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ),
                                      )
                                      .animate()
                                      .fade(duration: 600.ms)
                                      .slideY(begin: 0.2, end: 0)
                                : ListView.separated(
                                        shrinkWrap: true,
                                        primary: false,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: _localPlayers.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(
                                              height: 1,
                                              thickness: 0.5,
                                            ),
                                        itemBuilder: (context, index) =>
                                            _playerRow(
                                              _localPlayers[index],
                                              onTap: () =>
                                                  _showEditPlayerDialog(index),
                                            ),
                                      )
                                      .animate()
                                      .fade(duration: 400.ms)
                                      .slideY(begin: 0.1, end: 0),
                          ),
                        )
                        .animate()
                        .fade(duration: 600.ms)
                        .scale(
                          begin: const Offset(0.95, 0.95),
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                          onPressed: _showAddPlayerDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text("+ Spieler hinzufügen"),
                        )
                        .animate()
                        .fade(delay: 300.ms, duration: 600.ms)
                        .slideY(begin: 1, end: 0, curve: Curves.easeOutBack)
                        .shimmer(delay: 1000.ms, duration: 1500.ms),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _playerRow(String name, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const Icon(Icons.edit, color: Colors.black38, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
