import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'services/sync_manager.dart';
import 'screens/match_scoring_screen.dart';
import 'models/ball_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(BallEventAdapter());
  
  final syncManager = SyncManager();
  await syncManager.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => syncManager,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const MatchScoringScreen(matchId: 'm1', teamName: 'India'),
    );
  }
}
