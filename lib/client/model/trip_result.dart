import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:transi_flex_mobile/client/model/agency.dart';
import 'package:transi_flex_mobile/client/model/bus.dart';
import 'package:transi_flex_mobile/client/model/company.dart';
import 'package:transi_flex_mobile/client/model/trajet.dart';

class TripResult extends Equatable {
  final int scheduleId;
  final Trajet trajet;
  final DateTime dateDepart;
  final TimeOfDay heureDepart;
  final int placesDisponibles;
  final double prix;
  final Bus bus;
  final Company company;
  final Agency agency;

  const TripResult({
    required this.scheduleId,
    required this.trajet,
    required this.dateDepart,
    required this.heureDepart,
    required this.placesDisponibles,
    required this.prix,
    required this.bus,
    required this.company,
    required this.agency,
  });

  factory TripResult.fromJson(Map<String, dynamic> json) {
    final heureString = json['heureDepart'] ?? '00:00';
    final parts = heureString.split(':');
    final heure = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts.length > 1 ? parts[1] : '0'),
    );

    return TripResult(
      scheduleId: json['scheduleId'],
      trajet: Trajet.fromJson(json['trajet'] ?? {}),
      dateDepart: DateTime.parse(json['dateDepart']),
      heureDepart: heure,
      placesDisponibles: json['placesDisponibles'] ?? 0,
      prix: (json['prix'] ?? 0).toDouble(),
      bus: Bus.fromJson(json['bus'] ?? {}),
      company: Company.fromJson(json['company'] ?? {}),
      agency: Agency.fromJson(json['agency'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'trajet': trajet.toJson(),
      'dateDepart': dateDepart.toIso8601String(),
      'heureDepart': '${heureDepart.hour.toString().padLeft(2, '0')}:${heureDepart.minute.toString().padLeft(2, '0')}',
      'placesDisponibles': placesDisponibles,
      'prix': prix,
      'bus': bus.toJson(),
      'company': company.toJson(),
      'agency': agency.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    scheduleId,
    trajet,
    dateDepart,
    heureDepart,
    placesDisponibles,
    prix,
    bus,
    company,
    agency,
  ];
}