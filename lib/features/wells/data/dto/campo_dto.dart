import '../../domain/entities/campo.dart';

class CampoDto {
  const CampoDto(this.json);

  final Map<String, dynamic> json;

  Campo toEntity() => Campo.fromJson(json);
}
