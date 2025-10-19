import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/client/model/agency.dart';

import '../../authentification/model/user.dart';
import '../enums/colis_status.dart';
import 'colis_items.dart';

class Colis extends Equatable {
  final int? id;
  final String? numero;
  final String? expediteur;
  final String? destinateur;
  final String? heureEnvoi;
  final double? prix;
  final String? lieuEnvoi;
  final String? lieuReception;
  final int? companyId;
  final int? trajetId;
  final ColisStatus? status;
  final List<ColisItems>? colisItems;
  User? user;
  final Agency? agency;
  final DateTime? createdAt;

   Colis({
    this.id,
    this.numero,
    this.expediteur,
    this.destinateur,
    this.heureEnvoi,
    this.prix,
    this.lieuEnvoi,
    this.lieuReception,
    this.companyId,
    this.trajetId,
    this.status,
    this.colisItems,
    this.user,
     this.agency,
     this.createdAt
  });

  @override
  List<Object?> get props => [
    id, numero, expediteur, destinateur, heureEnvoi, prix,
    lieuEnvoi, lieuReception, companyId, trajetId, status, colisItems, user,
    agency, createdAt
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numero': numero,
      'expediteur': expediteur,
      'destinateur': destinateur,
      'heureEnvoi': heureEnvoi,
      'prix': prix,
      'lieuEnvoi': lieuEnvoi,
      'lieuReception': lieuReception,
      'companyId': companyId,
      'trajetId': trajetId,
      'status': status?.toString().split('.').last,
      'colisItems': colisItems?.map((e) => e.toJson()).toList(),
      'user': user?.toJson(),
      'agency': agency?.toJson(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id']?.toInt(),
      numero: json['numero'] as String?,
      expediteur: json['expediteur'] as String?,
      destinateur: json['destinateur'] as String?,
      heureEnvoi: json['heureEnvoi'] as String?,
      prix: (json['prix'] as num?)?.toDouble(),
      lieuEnvoi: json['lieuEnvoi'] as String?,
      lieuReception: json['lieuReception'] as String?,
      companyId: json['companyId']?.toInt(),
      trajetId: json['trajetId']?.toInt(),
      status: json['status'] != null
          ? ColisStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => ColisStatus.EN_ATTENTE
      )
          : null,
      colisItems: json['colisItems'] != null
          ? List<ColisItems>.from(
          (json['colisItems'] as List).map((e) => ColisItems.fromJson(e))
      )
          : null,
      agency: Agency.fromJson(json['agency'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String(),)
    );
  }
}