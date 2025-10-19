import 'package:equatable/equatable.dart';

class ColisItems extends Equatable {
  final int? id;
  final String? description;
  final int? nombre;
  final String? nature;

  const ColisItems({
    this.id,
    this.description,
    this.nombre,
    this.nature,
  });

  @override
  List<Object?> get props => [id, description, nombre, nature];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'nombre': nombre,
      'nature': nature,
    };
  }

  factory ColisItems.fromJson(Map<String, dynamic> json) {
    return ColisItems(
      id: json['id']?.toInt(),
      description: json['description'] as String?,
      nombre: json['nombre'] as int?,
      nature: json['nature'] as String?,
    );
  }
}
