import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PendaftaranService {
  static const String baseUrl = 'http://192.168.45.253:8000/api'; // Ganti dengan URL API Anda
  
  // Mendapatkan token dari SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Mendapatkan user_id dari SharedPreferences
  static Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('user_id');
  }

  // Membuat header dengan token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Membuat header untuk multipart (file upload)
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await _getToken();
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Mendaftar ke UKM
  static Future<Map<String, dynamic>> daftar({
    required int organisasiId,
    required int divisiId,
    required String nama,
    required String nim,
    required String prodi,
    required String nomorWa,
    required String semester,
    required String alasan,
    required File cvFile,
  }) async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      final uri = Uri.parse('$baseUrl/pendaftaran');
      final request = http.MultipartRequest('POST', uri);
      
      // Tambahkan headers
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);

      // Tambahkan data form
      request.fields['user_id'] = userId.toString();
      request.fields['organisasi_id'] = organisasiId.toString();
      request.fields['divisi_id'] = divisiId.toString();
      request.fields['nama'] = nama;
      request.fields['nim'] = nim;
      request.fields['prodi'] = prodi;
      request.fields['nomor_wa'] = nomorWa;
      request.fields['semester'] = semester;
      request.fields['alasan'] = alasan;

      // Tambahkan file CV
      final cvStream = http.ByteStream(cvFile.openRead());
      final cvLength = await cvFile.length();
      final cvMultipartFile = http.MultipartFile(
        'cv',
        cvStream,
        cvLength,
        filename: cvFile.path.split('/').last,
      );
      request.files.add(cvMultipartFile);

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Mendapatkan data pendaftaran berdasarkan user_id
  static Future<Map<String, dynamic>> getPendaftaranByUserId() async {
    try {
      final userId = await _getUserId();
      if (userId == null) {
        throw Exception('User tidak ditemukan. Silakan login kembali.');
      }

      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pendaftaran/$userId'),
        headers: headers,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Belum ada pendaftaran',
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update pendaftaran
  static Future<Map<String, dynamic>> updatePendaftaran({
    required int pendaftaranId,
    required int organisasiId,
    required int divisiId,
    required String nama,
    required String nim,
    required String prodi,
    required String nomorWa,
    required String semester,
    required String alasan,
    File? cvFile,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/pendaftaran/$pendaftaranId');
      final request = http.MultipartRequest('PUT', uri);
      
      // Tambahkan headers
      final headers = await _getMultipartHeaders();
      request.headers.addAll(headers);

      // Tambahkan data form
      request.fields['organisasi_id'] = organisasiId.toString();
      request.fields['divisi_id'] = divisiId.toString();
      request.fields['nama'] = nama;
      request.fields['nim'] = nim;
      request.fields['prodi'] = prodi;
      request.fields['nomor_wa'] = nomorWa;
      request.fields['semester'] = semester;
      request.fields['alasan'] = alasan;

      // Tambahkan file CV jika ada
      if (cvFile != null) {
        final cvStream = http.ByteStream(cvFile.openRead());
        final cvLength = await cvFile.length();
        final cvMultipartFile = http.MultipartFile(
          'cv',
          cvStream,
          cvLength,
          filename: cvFile.path.split('/').last,
        );
        request.files.add(cvMultipartFile);
      }

      // Kirim request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
          'errors': responseData['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // Update status seleksi (untuk admin)
  static Future<Map<String, dynamic>> updateStatusSeleksi({
    required int pendaftaranId,
    required String status,
    DateTime? jadwalWawancara,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/pendaftaran/seleksi/$pendaftaranId'),
        headers: headers,
        body: json.encode({
          'status': status,
          if (jadwalWawancara != null)
            'jadwal_wawancara': jadwalWawancara.toIso8601String(),
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseData['message'],
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Terjadi kesalahan',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}