import 'package:equatable/equatable.dart';

import '../enums/company_status.dart';

class Company extends Equatable {
  final int? id;
  final String? name;
  final String? address;
  final String? telephone;
  final String? postalCode;
  final String? city;
  final String? region;
  final String? email;
  final int? adminId;
  final String? adminFirstName;
  final String? adminLastName;
  final String? adminPhone;
  final String? adminEmail;
  final CompanyStatus? status;
  final String? logoPath;

  const Company({
    this.id,
    this.name,
    this.address,
    this.telephone,
    this.postalCode,
    this.city,
    this.region,
    this.email,
    this.adminId,
    this.adminFirstName,
    this.adminLastName,
    this.adminPhone,
    this.adminEmail,
    this.status,
    this.logoPath,
  });

  @override
  List<Object?> get props => [
    id, name, address, telephone, postalCode, city, region, email,
    adminId, adminFirstName, adminLastName, adminPhone, adminEmail, status, logoPath
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'telephone': telephone,
      'postalCode': postalCode,
      'city': city,
      'region': region,
      'email': email,
      'adminId': adminId,
      'adminFirstName': adminFirstName,
      'adminLastName': adminLastName,
      'adminPhone': adminPhone,
      'adminEmail': adminEmail,
      'status': status?.toString().split('.').last,
      'logoPath': logoPath,
    };
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id']?.toInt(),
      name: json['name'] as String?,
      address: json['address'] as String?,
      telephone: json['telephone'] as String?,
      postalCode: json['postalCode'] as String?,
      city: json['city'] as String?,
      region: json['region'] as String?,
      email: json['email'] as String?,
      adminId: json['adminId']?.toInt(),
      adminFirstName: json['adminFirstName'] as String?,
      adminLastName: json['adminLastName'] as String?,
      adminPhone: json['adminPhone'] as String?,
      adminEmail: json['adminEmail'] as String?,
      status: json['status'] != null
          ? CompanyStatus.values.firstWhere(
              (e) => e.toString().split('.').last == json['status'],
          orElse: () => CompanyStatus.ACTIVE
      )
          : null,
      logoPath: json['logoPath'] as String?,
    );
  }
}