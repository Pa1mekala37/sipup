class CustomContainer {
  final String id;
  final String name;
  final int volumeMl;
  final String emoji;
  final int sortOrder;

  const CustomContainer({
    required this.id,
    required this.name,
    required this.volumeMl,
    required this.emoji,
    required this.sortOrder,
  });

  CustomContainer copyWith({
    String? name,
    int? volumeMl,
    String? emoji,
    int? sortOrder,
  }) {
    return CustomContainer(
      id: id,
      name: name ?? this.name,
      volumeMl: volumeMl ?? this.volumeMl,
      emoji: emoji ?? this.emoji,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
