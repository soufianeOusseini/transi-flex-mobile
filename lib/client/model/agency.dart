import 'package:equatable/equatable.dart';

import '../enums/agency_status.dart';
import 'company.dart';

class Agency extends Equatable {
  final int? id;
  final String? name;
  final String? code;
  final String? address;
  final String? telephone;
  final String? city;
  final String? region;
  final String? email;
  final String? managerName;
  final String? managerPhone;
  final AgencyStatus? status;
  final int? companyId;
  final String? companyName;
  final String? createdAt;
  final String? updatedAt;
  final Company? company;
  const Agency({
    this.id,
    this.name,
    this.code,
    this.address,
    this.telephone,
    this.city,
    this.region,
    this.email,
    this.managerName,
    this.managerPhone,
    this.status,
    this.companyId,
    this.companyName,
    this.createdAt,
    this.updatedAt,
    this.company
  });

  @override
  List<Object?> get props => [
    id, name, code, address, telephone, city, region, email, company,
    managerName, managerPhone, status, companyId, companyName, createdAt, updatedAt
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'address': address,
      'telephone': telephone,
      'city': city,
      'region': region,
      'email': email,
      'managerName': managerName,
      'managerPhone': managerPhone,
      'status': status?.toString().split('.').last,
      'companyId': companyId,
      'companyName': companyName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'company': company?.toJson()
    };
  }

  factory Agency.fromJson(Map<String, dynamic> json) {
    return Agency(
      id: json['id']?.toInt(),
      name: json['name'] as String?,
      code: json['code'] as String?,
      address: json['address'] as String?,
      telephone: json['telephone'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      email: json['email'] as String?,
      managerName: json['managerName'] as String?,
      managerPhone: json['managerPhone'] as String?,
      status: json['status'] != null
          ? AgencyStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => AgencyStatus.ACTIVE
      )
          : null,
      companyId: json['companyId']?.toInt(),
      companyName: json['companyName'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      company: Company.fromJson(json['company'] ?? {}),
    );
  }
}