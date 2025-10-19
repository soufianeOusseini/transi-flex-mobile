import 'package:equatable/equatable.dart';

import '../enums/trajet_status.dart';

class Trajet extends Equatable {
  final int? id;
  final String? nom;
  final String? villeDepart;
  final String? villeArrive;
  final double? km;
  final String? heure;
  final TrajetStatus? status;
  final int? companyId;
  final double? amount;

  const Trajet({
    this.id,
    this.nom,
    this.villeDepart,
    this.villeArrive,
    this.km,
    this.heure,
    this.status,
    this.companyId,
    this.amount,
  });

  @override
  List<Object?> get props => [
    id, nom, villeDepart, villeArrive, km, heure, status, companyId, amount
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'villeDepart': villeDepart,
      'villeArrive': villeArrive,
      'km': km,
      'heure': heure,
      'status': status?.toString().split('.').last,
      'companyId': companyId,
      'amount': amount,
    };
  }

  factory Trajet.fromJson(Map<String, dynamic> json) {
    return Trajet(
      id: json['id']?.toInt(),
      nom: json['nom'] as String?,
      villeDepart: json['villeDepart'] as String?,
      villeArrive: json['villeArrive'] as String?,
      km: (json['km'] as num?)?.toDouble(),
      heure: json['heure'] as String?,
      status: json['status'] != null
          ? TrajetStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => TrajetStatus.PLANIFIE
      )
          : null,
      companyId: json['companyId']?.toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}