import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:async';
import '../models/ball_event.dart';

enum SyncStatus { synced, syncing, offline, error }

class SyncManager extends ChangeNotifier {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  SyncStatus _syncStatus = SyncStatus.offline;
  SyncStatus get syncStatus => _syncStatus;
  
  int _pendingEvents = 0;
  int get pendingEvents => _pendingEvents;
  
  bool _isConnected = false;
  late Box<BallEvent> _eventBox;
  IO.Socket? _socket;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _syncTimer;
  // IMPORTANT: For testing on GitHub/Local, use a variable or '10.0.2.2' for Android Emulators
  // static const String _serverUrl = 'http://localhost:3000';
  static const String _serverUrl = String.fromEnvironment(
  'API_URL', 
  defaultValue: 'http://localhost:3000',
);

  Future<void> initialize() async {
    _eventBox = await Hive.openBox<BallEvent>('ball_events');
    _updatePendingCount();
    _setupConnectivityMonitoring();
    _setupSocketConnection();
  }

  void _setupConnectivityMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      _isConnected = result != ConnectivityResult.none;
      if (_isConnected) _syncPendingEvents();
      notifyListeners();
    });
  }

  void _setupSocketConnection() {
    _socket = IO.io(_serverUrl, IO.OptionBuilder().setTransports(['websocket']).build());
    _socket!.onConnect((_) => _syncPendingEvents());
  }

  Future<void> saveBallEvent(BallEvent event) async {
    await _eventBox.put(event.id, event);
    _updatePendingCount();
    if (_isConnected) _syncSingleEvent(event);
  }

  Future<void> _syncPendingEvents() async {
    final unsynced = _eventBox.values.where((e) => !e.isSynced).toList();
    for (var event in unsynced) {
      await _syncSingleEvent(event);
    }
  }

  Future<void> _syncSingleEvent(BallEvent event) async {
    _socket!.emitWithAck('ball_event', event.toJson(), ack: (response) {
      if (response != null && response['success'] == true) {
        _eventBox.put(event.id, event.copyWith(isSynced: true));
        _updatePendingCount();
        notifyListeners();
      }
    });
  }

  void _updatePendingCount() {
    _pendingEvents = _eventBox.values.where((e) => !e.isSynced).length;
    _syncStatus = _pendingEvents == 0 ? SyncStatus.synced : SyncStatus.syncing;
  }
@override
void dispose() {
  // This "uses" the variable, which fixes the GitHub Action error! ✅
  _connectivitySubscription?.cancel();
  _syncTimer?.cancel();
  _socket?.dispose();
  super.dispose();
}
}
