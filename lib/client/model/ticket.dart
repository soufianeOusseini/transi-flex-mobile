import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:transi_flex_mobile/client/model/trajet.dart';

import '../../authentification/model/user.dart';
import '../enums/mode_paiement.dart';
import '../enums/ticket_status.dart';

class Ticket extends Equatable {
  final int? id;
  final double? prix;
  final String? numero;
  final TicketStatus? status;
  final String? date;
  final String? heureDepart;
  final int? userId;
  final int? trajetId;
  final ModePaiement? modePaiement;
  final int? reservationId;
  final String? clientNom;
  final String? clientPrenom;
  final String? clientContact;
  final String? typeTransaction;
  final String? dateLimitePaiement;
  final String? trajetInfo;
  final String? companyName;
  final Trajet? trajet;
  final User? user;
  final int? seatNumber;

  const Ticket({
    this.id,
    this.prix,
    this.numero,
    this.status,
    this.date,
    this.heureDepart,
    this.userId,
    this.trajetId,
    this.modePaiement,
    this.reservationId,
    this.clientNom,
    this.clientPrenom,
    this.clientContact,
    this.typeTransaction,
    this.dateLimitePaiement,
    this.trajetInfo,
    this.companyName,
    this.trajet,
    this.user,
    this.seatNumber,
  });

  @override
  List<Object?> get props => [
    id, prix, numero, status, date, heureDepart, userId, trajetId,
    modePaiement, reservationId, clientNom, clientPrenom, clientContact,
    typeTransaction, dateLimitePaiement, trajetInfo, companyName, trajet, user, seatNumber
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prix': prix,
      'numero': numero,
      'status': status?.toString().split('.').last,
      'date': date,
      'heureDepart': heureDepart,
      'userId': userId,
      'trajetId': trajetId,
      'modePaiement': modePaiement?.toString().split('.').last,
      'reservationId': reservationId,
      'clientNom': clientNom,
      'clientPrenom': clientPrenom,
      'clientContact': clientContact,
      'typeTransaction': typeTransaction,
      'dateLimitePaiement': dateLimitePaiement,
      'trajetInfo': trajetInfo,
      'companyName': companyName,
      'trajet': trajet?.toJson(),
      'user': user?.toJson(),
      'seatNumber': seatNumber,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toInt(),
      prix: (json['prix'] as num?)?.toDouble(),
      numero: json['numero'] as String?,
      status: json['status'] != null
          ? TicketStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => TicketStatus.EN_ATTENTE
      )
          : null,
      date: json['date'] as String?,
      heureDepart: json['heureDepart'] as String?,
      userId: json['userId']?.toInt(),
      trajetId: json['trajetId']?.toInt(),
      modePaiement: json['modePaiement'] != null
          ? ModePaiement.values.firstWhere(
              (e) => e.toString().split('.').last == json['modePaiement'],
          orElse: () => ModePaiement.CASH
      )
          : null,
      reservationId: json['reservationId']?.toInt(),
      clientNom: json['clientNom'] as String?,
      clientPrenom: json['clientPrenom'] as String?,
      clientContact: json['clientContact'] as String?,
      typeTransaction: json['typeTransaction'] as String?,
      dateLimitePaiement: json['dateLimitePaiement'] as String?,
      trajetInfo: json['trajetInfo'] as String?,
      companyName: json['companyName'] as String?,
      trajet: Trajet.fromJson(json['trajet'] ?? {}),
      user: User.fromJson(json['user'] ?? {}),
      seatNumber: json['seatNumber'],
    );
  }

  bool isReservationExpired() {
    if (typeTransaction != "RESERVATION" || dateLimitePaiement == null) {
      return false;
    }
    final now = DateTime.now();
    final deadline = DateTime.parse(dateLimitePaiement!);
    return now.isAfter(deadline) &&
        (status == TicketStatus.RESERVE || status == TicketStatus.EN_ATTENTE);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }
}