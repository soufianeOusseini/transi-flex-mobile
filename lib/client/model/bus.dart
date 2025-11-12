import 'package:equatable/equatable.dart';
class Bus extends Equatable {
  final int? id;
  final int? capacity;

  const Bus({
    this.id,
    this.capacity,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'capacity': capacity,
    };
  }

  @override
  List<Object?> get props => [id, capacity];
}