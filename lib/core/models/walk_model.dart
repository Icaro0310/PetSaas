/// Registo de um passeio do pet — varios passeios por dia sao permitidos.
/// `poop`/`pee` marcam as necessidades observadas durante o passeio.
class WalkModel {
  final String id;
  final String petId;
  final DateTime walkedAt;
  final bool poop;
  final bool pee;
  final int? durationMinutes;
  final String? notes;
  final String loggedBy;

  const WalkModel({
    required this.id,
    required this.petId,
    required this.walkedAt,
    required this.poop,
    required this.pee,
    this.durationMinutes,
    this.notes,
    required this.loggedBy,
  });

  factory WalkModel.fromJson(Map<String, dynamic> json) {
    return WalkModel(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      walkedAt: DateTime.parse(json['walked_at'] as String).toLocal(),
      poop: json['poop'] as bool? ?? false,
      pee: json['pee'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int?,
      notes: json['notes'] as String?,
      loggedBy: json['logged_by'] as String? ?? '',
    );
  }
}
