// lib/models/status_model.dart
import 'package:flutter/material.dart';

class StatusUKM {
  final int id;
  final String name;
  final String category;
  final String registrationDate;
  final String status;
  final Color statusColor;
  final String logoPath;
  final String description;
  final String? alasan;
  final String? divisi;
  final String? jadwalWawancara;

  StatusUKM({
    required this.id,
    required this.name,
    required this.category,
    required this.registrationDate,
    required this.status,
    required this.statusColor,
    required this.logoPath,
    required this.description,
    this.alasan,
    this.divisi,
    this.jadwalWawancara,
  });

  factory StatusUKM.fromJson(Map<String, dynamic> json) {
    // Tentukan warna berdasarkan status
    Color statusColor;
    switch (json['status']?.toLowerCase()) {
      case 'diterima':
        statusColor = Color(0xFF10B981); // Green
        break;
      case 'ditolak':
        statusColor = Color(0xFFEF4444); // Red
        break;
      case 'pending':
      default:
        statusColor = Color(0xFFF59E0B); // Yellow
        break;
    }

    return StatusUKM(
      id: json['id'] ?? 0,
      name: json['organisasi']?['nama'] ?? 'Unknown',
      category: json['organisasi']?['kategori'] ?? 'Tidak Diketahui',
      registrationDate: _formatDate(json['created_at']),
      status: _getStatusText(json['status']),
      statusColor: statusColor,
      logoPath: json['organisasi']?['logo'] ?? 'images/polbeng_logo.png',
      description: json['organisasi']?['deskripsi'] ?? 'Tidak ada deskripsi',
      alasan: json['alasan'],
      divisi: json['divisi']?['nama'],
      jadwalWawancara: json['jadwal_wawancara'],
    );
  }

  static String _formatDate(String? dateString) {
    if (dateString == null) return 'Tidak diketahui';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Tidak diketahui';
    }
  }

  static String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'diterima':
        return 'Diterima';
      case 'ditolak':
        return 'Ditolak';
      case 'pending':
      default:
        return 'Menunggu';
    }
  }
}

// Model untuk response API
class PendaftaranResponse {
  final bool success;
  final String? message;
  final List<StatusUKM>? data;
  final StatusUKM? singleData;

  PendaftaranResponse({
    required this.success,
    this.message,
    this.data,
    this.singleData,
  });

  factory PendaftaranResponse.fromJson(Map<String, dynamic> json) {
    if (json['success'] == false) {
      return PendaftaranResponse(
        success: false,
        message: json['message'],
      );
    }

    // Jika data adalah array
    if (json['data'] is List) {
      List<StatusUKM> statusList = [];
      for (var item in json['data']) {
        statusList.add(StatusUKM.fromJson(item));
      }
      return PendaftaranResponse(
        success: true,
        data: statusList,
      );
    }
    
    // Jika data adalah object tunggal
    else if (json['data'] is Map<String, dynamic>) {
      return PendaftaranResponse(
        success: true,
        singleData: StatusUKM.fromJson(json['data']),
      );
    }

    return PendaftaranResponse(
      success: false,
      message: 'Format data tidak valid',
    );
  }
}