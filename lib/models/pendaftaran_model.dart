import 'package:flutter/material.dart';
class Pendaftaran {
  final int id;
  final int userId;
  final int organisasiId;
  final int divisiId;
  final String nama;
  final String nim;
  final String prodi;
  final String nomorWa;
  final String semester;
  final String alasan;
  final String cv;
  final String status;
  final DateTime? jadwalWawancara;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Organisasi? organisasi;
  final Divisi? divisi;

  Pendaftaran({
    required this.id,
    required this.userId,
    required this.organisasiId,
    required this.divisiId,
    required this.nama,
    required this.nim,
    required this.prodi,
    required this.nomorWa,
    required this.semester,
    required this.alasan,
    required this.cv,
    required this.status,
    this.jadwalWawancara,
    required this.createdAt,
    required this.updatedAt,
    this.organisasi,
    this.divisi,
  });

  factory Pendaftaran.fromJson(Map<String, dynamic> json) {
    return Pendaftaran(
      id: json['id'],
      userId: json['user_id'],
      organisasiId: json['organisasi_id'],
      divisiId: json['divisi_id'],
      nama: json['nama'],
      nim: json['nim'],
      prodi: json['prodi'],
      nomorWa: json['nomor_wa'],
      semester: json['semester'],
      alasan: json['alasan'],
      cv: json['cv'],
      status: json['status'],
      jadwalWawancara: json['jadwal_wawancara'] != null 
          ? DateTime.parse(json['jadwal_wawancara'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      organisasi: json['organisasi'] != null 
          ? Organisasi.fromJson(json['organisasi'])
          : null,
      divisi: json['divisi'] != null 
          ? Divisi.fromJson(json['divisi'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'organisasi_id': organisasiId,
      'divisi_id': divisiId,
      'nama': nama,
      'nim': nim,
      'prodi': prodi,
      'nomor_wa': nomorWa,
      'semester': semester,
      'alasan': alasan,
      'cv': cv,
      'status': status,
      'jadwal_wawancara': jadwalWawancara?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'organisasi': organisasi?.toJson(),
      'divisi': divisi?.toJson(),
    };
  }

  // Helper method untuk mendapatkan status dalam bahasa Indonesia
  String get statusIndonesia {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // Helper method untuk mendapatkan warna status
  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class Organisasi {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Organisasi({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Organisasi.fromJson(Map<String, dynamic> json) {
    return Organisasi(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      logo: json['logo'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class Divisi {
  final int id;
  final String name;
  final String? description;
  final int organisasiId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Divisi({
    required this.id,
    required this.name,
    this.description,
    required this.organisasiId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Divisi.fromJson(Map<String, dynamic> json) {
    return Divisi(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      organisasiId: json['organisasi_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'organisasi_id': organisasiId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}