class WaterLog {
  final String id;
  final int amountMl;
  final DateTime timestamp;
  final String containerName;
  final String containerEmoji;

  const WaterLog({
    required this.id,
    required this.amountMl,
    required this.timestamp,
    required this.containerName,
    required this.containerEmoji,
  });
}
