import 'package:flutter/material.dart';
import 'package:hitsterclone/GamePage.dart';

class Playerselect extends StatefulWidget {
  const Playerselect({super.key});

  @override
  State<Playerselect> createState() => _PlayerselectState();
}

class _PlayerselectState extends State<Playerselect> {
  final List<String> players = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        players.add(_nameController.text);
        _nameController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Players')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Player Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _addPlayer,
                  child: const Text('Add Player'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(players[index]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        players.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamePage()),
              ),
            },
            child: Text("Start Game"),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
