import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/organisasi_model.dart';
import '/services/local_storage.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl =
      'http://192.168.45.253:8000/api'; // Ganti dengan URL API Anda

  static Future<Map<String, String>> getHeaders() async {
    final token = await LocalStorage.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  static Future<Map<String, dynamic>> getPendaftaranByUserId(int userId) async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pendaftaran/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'message': 'Pendaftaran tidak ditemukan',
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data pendaftaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
  static Future<Map<String, dynamic>> getAllPendaftaranUser() async {
    try {
      final headers = await getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/pendaftaran/user/all'), // Endpoint baru yang perlu dibuat
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Gagal mengambil data pendaftaran',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // GET: Mendapatkan semua organisasi
  static Future<List<OrganisasiModel>> getAllOrganisasi(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organisasi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Cek apakah respons adalah List atau Map
        final dynamic data = json.decode(response.body);
        List<dynamic> organisasiList;

        if (data is List) {
          organisasiList = data; // Respons langsung berupa list
        } else if (data is Map<String, dynamic>) {
          organisasiList = data['data'] ?? []; // Respons dengan kunci 'data'
        } else {
          throw Exception('Format respons API tidak didukung');
        }

        return organisasiList
            .map((json) => OrganisasiModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load organisasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET: Mendapatkan organisasi berdasarkan ID
  static Future<OrganisasiModel> getOrganisasiById(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organisasi/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return OrganisasiModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to load organisasi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET: Mendapatkan divisi berdasarkan organisasi ID
  static Future<List<DivisiModel>> getDivisiByOrganisasiId(
    int organisasiId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/organisasi/$organisasiId/divisi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> divisiList = data['data'] ?? [];

        return divisiList.map((json) => DivisiModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load divisi: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET: Fetch user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
  try {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody['data'] == null) {
        throw Exception('Data profil tidak ditemukan di response');
      }

      return responseBody['data'];
    } else {
      throw Exception('Failed to load profile: ${response.body}');
    }
  } catch (e) {
    throw Exception('Network error: $e');
  }
}


  // PUT: Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String nama,
    required String nim,
    required String jurusanId,
    required String nomorHp,
    required String semester,
  }) async {
    try {
      final headers = await getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/user/update'),
        headers: headers,
        body: jsonEncode({
          'nama': nama, // Match Laravel controller field names
          'nim': nim,
          'jurusan': jurusanId,
          'nomor_hp': nomorHp,
          'semester': semester,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        return responseBody['data'];
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<Map<String, dynamic>> uploadProfilePhoto(File file) async {
    final token = await LocalStorage.getToken(); // Ambil token dulu
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/upload-photo'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('foto', file.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final result = jsonDecode(responseData);

    if (response.statusCode == 200 && result['success']) {
      return result;
    } else {
      throw Exception(result['message'] ?? 'Upload gagal');
    }
  }
}
