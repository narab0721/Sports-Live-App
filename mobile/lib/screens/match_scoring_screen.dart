import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/sync_manager.dart';
import '../models/ball_event.dart';

class MatchScoringScreen extends StatelessWidget {
  final String matchId;
  final String teamName;

  const MatchScoringScreen({super.key, required this.matchId, required this.teamName});

  @override
  Widget build(BuildContext context) {
    final syncManager = context.watch<SyncManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text('$teamName Scoring'),
        actions: [
          Icon(
            syncManager.syncStatus == SyncStatus.synced ? Icons.cloud_done : Icons.cloud_upload,
            color: syncManager.syncStatus == SyncStatus.synced ? Colors.green : Colors.orange,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('${syncManager.pendingEvents} pending')),
          )
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final event = BallEvent(
              id: DateTime.now().toString(),
              matchId: matchId,
              runs: 1,
              batsmanName: 'Player 1',
              bowlerName: 'Bowler 1',
              over: 0.1,
              timestamp: DateTime.now(),
            );
            syncManager.saveBallEvent(event);
          },
          child: const Text('Add 1 Run'),
        ),
      ),
    );
  }
}
