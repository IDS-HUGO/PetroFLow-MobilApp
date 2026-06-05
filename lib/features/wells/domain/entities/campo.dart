class Campo {
  const Campo({
    required this.id,
    required this.name,
    required this.createdAt,
    this.region,
  });

  final String id;
  final String name;
  final String? region;
  final DateTime? createdAt;

  String get label =>
      region == null || region!.isEmpty ? name : '$name · $region';

  factory Campo.fromJson(Map<String, dynamic> json) {
    return Campo(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      region: json['region']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
