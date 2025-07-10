import '../models/organisasi_model.dart';
import 'api_service.dart';

class OrganisasiService {
  // Mendapatkan semua organisasi dengan error handling
  static Future<List<OrganisasiModel>> fetchAllOrganisasi(String token) async {
  try {
    return await ApiService.getAllOrganisasi(token);
  } catch (e) {
    print('Error fetching organisasi: $e');
    rethrow;
  }
}


  // Mendapatkan organisasi berdasarkan ID
  static Future<OrganisasiModel> fetchOrganisasiById(int id, String token) async {
    try {
      return await ApiService.getOrganisasiById(id, token);
    } catch (e) {
      print('Error fetching organisasi by ID: $e');
      rethrow;
    }
  }

  // Mendapatkan divisi berdasarkan organisasi ID
  static Future<List<DivisiModel>> fetchDivisiByOrganisasiId(int organisasiId, String token) async {
    try {
      return await ApiService.getDivisiByOrganisasiId(organisasiId, token);
    } catch (e) {
      print('Error fetching divisi: $e');
      rethrow;
    }
  }

  // Filter organisasi berdasarkan tipe
  static List<OrganisasiModel> filterOrganisasiByTipe(
    List<OrganisasiModel> organisasiList, 
    String tipe
  ) {
    if (tipe == 'Semua') return organisasiList;
    return organisasiList.where((org) => org.tipe == tipe).toList();
  }

  // Mencari organisasi berdasarkan nama
  static List<OrganisasiModel> searchOrganisasi(
    List<OrganisasiModel> organisasiList, 
    String query
  ) {
    if (query.isEmpty) return organisasiList;
    return organisasiList.where((org) => 
      org.nama.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}