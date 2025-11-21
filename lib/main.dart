import 'package:flutter/material.dart';
import 'package:hitsterclone/AppleTestPage.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/StartUpPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Logicservice(),
      child: Consumer<Logicservice>(
        builder: (context, logic, _) {
          return FutureBuilder<void>(
            future: logic.initFuture,
            builder: (context, snapshot) {
              final ready = snapshot.connectionState == ConnectionState.done;
              return MaterialApp(
                title: 'Hipster Clone',
                home: SetupPage(),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
