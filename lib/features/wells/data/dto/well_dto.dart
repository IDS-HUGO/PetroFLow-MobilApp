import '../../domain/entities/well.dart';

class WellDto {
  const WellDto(this.json);

  final Map<String, dynamic> json;

  Well toEntity() => Well.fromJson(json);
}
