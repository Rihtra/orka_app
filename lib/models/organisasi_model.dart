class OrganisasiModel {
  final int id;
  final String nama;
  final int? jurusanId;
  final int? adminUserId;
  final String? deskripsi;
  final String? logoUrl;
  final String? visi;
  final String? misi;
  final String? syarat;
  final String? tipe;
  final String? createdAt;
  final String? updatedAt;
  final JurusanModel? jurusan;
  final AdminUserModel? adminUser;
  final List<DivisiModel>? divisis;
  final String? role;
  final Map<String, dynamic> struktur;
  final int? jumlahAnggota;

  OrganisasiModel({
    required this.id,
    required this.nama,
    this.jurusanId,
    this.adminUserId,
    this.deskripsi,
    this.logoUrl,
    this.visi,
    this.misi,
    this.syarat,
    this.tipe,
    this.createdAt,
    this.updatedAt,
    this.jurusan,
    this.adminUser,
    this.divisis,
    this.role,
    required this.struktur,
    this.jumlahAnggota
  });

  factory OrganisasiModel.fromJson(Map<String, dynamic> json) {
    return OrganisasiModel(
      id: json['id'],
      nama: json['nama'],
      jurusanId: json['jurusan_id'],
      adminUserId: json['admin_user_id'],
      deskripsi: json['deskripsi'],
      logoUrl: json['logo_url'],
      visi: json['visi'],
      misi: json['misi'],
      syarat: json['syarat'],
      tipe: json['tipe'],
      struktur: json['struktur'] != null && json['struktur'] is Map<String, dynamic>
    ? json['struktur']
    : {},
      jumlahAnggota: json['jumlah_anggota'] is int 
    ? json['jumlah_anggota'] 
    : int.tryParse(json['jumlah_anggota']?.toString() ?? '0'),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      jurusan: json['jurusan'] != null 
          ? JurusanModel.fromJson(json['jurusan']) 
          : null,
      adminUser: json['admin_user'] != null 
          ? AdminUserModel.fromJson(json['admin_user']) 
          : null,
      divisis: json['divisis'] != null
          ? (json['divisis'] as List)
              .map((divisi) => DivisiModel.fromJson(divisi))
              .toList()
          : null,
      role: json['pivot'] != null ? json['pivot']['role'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jurusan_id': jurusanId,
      'admin_user_id': adminUserId,
      'deskripsi': deskripsi,
      'logo_url': logoUrl,
      'visi': visi,
      'misi': misi,
      'syarat': syarat,
      'tipe': tipe,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'jurusan': jurusan?.toJson(),
      'admin_user': adminUser?.toJson(),
      'struktur': struktur,
      'jumlah_anggota': jumlahAnggota,
      'divisis': divisis?.map((divisi) => divisi.toJson()).toList(),
      'pivot': role != null ? {'role': role} : null,
    };
  }
}

class JurusanModel {
  final int id;
  final String nama;

  JurusanModel({
    required this.id,
    required this.nama,
  });

  factory JurusanModel.fromJson(Map<String, dynamic> json) {
    return JurusanModel(
      id: json['id'],
      nama: json['nama'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}

class AdminUserModel {
  final int id;
  final String name;
  final String email;

  AdminUserModel({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

class DivisiModel {
  final int id;
  final String nama;
  final int? organisasiId;

  DivisiModel({
    required this.id,
    required this.nama,
    this.organisasiId,
  });

  factory DivisiModel.fromJson(Map<String, dynamic> json) {
    try {
      return DivisiModel(
        id: json['id'],
        nama: json['nama'],
        organisasiId: json['organisasi_id'], // Bisa null
      );
    } catch (e) {
      print('Error parsing DivisiModel: $e');
      return DivisiModel(id: 0, nama: 'Unknown'); // Fallback
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'organisasi_id': organisasiId,
    };
  }
}