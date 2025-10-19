import 'package:equatable/equatable.dart';
import 'package:transi_flex_mobile/client/model/agency.dart';
import 'package:transi_flex_mobile/client/model/ticket.dart';

import 'colis.dart';
import 'company.dart';

class MobileApp extends Equatable {
  final List<Company>? companies;
  final List<Ticket>? tickets;
  final List<Colis>? colis;
  final List<Agency>? agencies;

  const MobileApp({
    this.companies,
    this.tickets,
    this.colis,
    this.agencies
  });

  @override
  List<Object?> get props => [companies, tickets, colis, agencies];

  Map<String, dynamic> toJson() {
    return {
      'companies': companies?.map((e) => e.toJson()).toList(),
      'tickets': tickets?.map((e) => e.toJson()).toList(),
      'colis': colis?.map((e) => e.toJson()).toList(),
      'agencies': agencies?.map((a) => a.toJson()).toList()
    };
  }

  factory MobileApp.fromJson(Map<String, dynamic> json) {
    return MobileApp(
      companies: json['companies'] != null
          ? List<Company>.from(
          (json['companies'] as List).map((e) => Company.fromJson(e))
      )
          : null,
      tickets: json['tickets'] != null
          ? List<Ticket>.from(
          (json['tickets'] as List).map((e) => Ticket.fromJson(e))
      )
          : null,
      colis: json['colis'] != null
          ? List<Colis>.from(
          (json['colis'] as List).map((e) => Colis.fromJson(e))
      )
          : null,
      agencies: json['agencies'] != null
          ? List<Agency>.from(
          (json['agencies'] as List).map((e) => Agency.fromJson(e))
      )
          : null,
    );
  }
}