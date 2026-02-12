import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hitsterclone/SetupPage.dart';
import 'package:hitsterclone/StartUpPage.dart';
import 'package:hitsterclone/services/LogicService.dart';
import 'package:hitsterclone/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    print(".env missing");
  }
  dotenv.env.forEach((key, value) {
    print('$key: $value');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                home: ready
                    ? (logic.hasSeenStartup
                          ? const SetupPage()
                          : const StartUpPage())
                    : const Scaffold(body: SizedBox()),
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
