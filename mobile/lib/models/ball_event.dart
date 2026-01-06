import 'package:hive/hive.dart';

// This line tells Hive to look for the generated file
part 'ball_event.g.dart'; 

@HiveType(typeId: 0)
class BallEvent extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String matchId;

  @HiveField(2)
  final int runs;

  @HiveField(3)
  final bool isWicket;

  @HiveField(4)
  final String? wicketType;

  @HiveField(5)
  final String? extraType;

  @HiveField(6)
  final int extraRuns;

  @HiveField(7)
  final String batsmanName;

  @HiveField(8)
  final String bowlerName;

  @HiveField(9)
  final double over;

  @HiveField(10)
  final DateTime timestamp;

  @HiveField(11)
  final bool isSynced;

  @HiveField(12)
  final String? commentary;

  BallEvent({
    required this.id,
    required this.matchId,
    required this.runs,
    this.isWicket = false,
    this.wicketType,
    this.extraType,
    this.extraRuns = 0,
    required this.batsmanName,
    required this.bowlerName,
    required this.over,
    required this.timestamp,
    this.isSynced = false,
    this.commentary,
  });

  // Converts the object to JSON for the Node.js server
  Map<String, dynamic> toJson() => {
    'id': id,
    'matchId': matchId,
    'runs': runs,
    'isWicket': isWicket,
    'wicketType': wicketType,
    'extraType': extraType,
    'extraRuns': extraRuns,
    'batsmanName': batsmanName,
    'bowlerName': bowlerName,
    'over': over,
    'timestamp': timestamp.toIso8601String(),
    'commentary': commentary,
  };

  // Helps update the 'isSynced' status without changing other data
  BallEvent copyWith({bool? isSynced}) {
    return BallEvent(
      id: id,
      matchId: matchId,
      runs: runs,
      isWicket: isWicket,
      wicketType: wicketType,
      extraType: extraType,
      extraRuns: extraRuns,
      batsmanName: batsmanName,
      bowlerName: bowlerName,
      over: over,
      timestamp: timestamp,
      isSynced: isSynced ?? this.isSynced,
      commentary: commentary,
    );
  }
}
