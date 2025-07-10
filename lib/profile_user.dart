import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/api_service.dart';
import 'navbar_button.dart'; // Your custom navbar
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileUserPage extends StatefulWidget {
  @override
  _ProfileUserPageState createState() => _ProfileUserPageState();
}

class _ProfileUserPageState extends State<ProfileUserPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 2;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
    _fetchUserProfile();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      try {
        final updatedData = await ApiService.uploadProfilePhoto(imageFile);

        // Validasi response
        if (updatedData != null && updatedData.containsKey('foto')) {
          setState(() {
            userData?['photoPath'] = updatedData['foto'];
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Foto berhasil diperbarui')));
        } else {
          throw Exception('Response tidak valid dari server');
        }
      } catch (e) {
        print('Upload error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal upload foto: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('Fetching user profile...');
      final data = await ApiService.getUserProfile();
      print('API Response: $data');

      // Validasi response
      if (data == null) {
        throw Exception('Server mengembalikan response null');
      }

      if (data is! Map<String, dynamic>) {
        throw Exception('Format response tidak valid: ${data.runtimeType}');
      }

      setState(() {
        userData = {
          'nama': data['name']?.toString() ?? 'Unknown',
          'nim': data['nim']?.toString() ?? 'N/A',
          'status': 'Mahasiswa', // Adjust if API provides this
          'jurusan': data['jurusan']?['nama']?.toString() ?? 'N/A',
          'email': data['email']?.toString() ?? 'N/A',
          'nomor_hp': data['no_hp']?.toString() ?? 'N/A',
          'semester': data['semester']?.toString() ?? 'N/A',
          'photoPath':
              data['foto'] != null
                  ? 'http://192.168.45.253:8000/${data['foto']}'
                  : null,
          'organisasi': data['organisasi'] is List ? data['organisasi'] : [],
        };
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching profile: $e');
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else if (index == 1) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/cek_status',
        (route) => false,
      );
    } else if (index == 2) {
      Navigator.pushNamedAndRemoveUntil(context, '/profile', (route) => false);
    }
  }

  void _showEditProfileDialog() {
    if (userData == null) return;

    final namaController = TextEditingController(text: userData?['nama']);
    final nimController = TextEditingController(text: userData?['nim']);
    final jurusanController = TextEditingController(text: userData?['jurusan']);
    final nomorHpController = TextEditingController(
      text: userData?['nomor_hp'],
    );
    final semesterController = TextEditingController(
      text: userData?['semester'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profil', style: GoogleFonts.poppins()),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: InputDecoration(labelText: 'Nama'),
                ),
                TextField(
                  controller: nimController,
                  decoration: InputDecoration(labelText: 'NIM'),
                ),
                TextField(
                  controller: jurusanController,
                  decoration: InputDecoration(labelText: 'Jurusan'),
                ),
                TextField(
                  controller: nomorHpController,
                  decoration: InputDecoration(labelText: 'No. Handphone'),
                ),
                TextField(
                  controller: semesterController,
                  decoration: InputDecoration(labelText: 'Semester'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final updatedData = await ApiService.updateUserProfile(
                    nama: namaController.text,
                    nim: nimController.text,
                    jurusanId: jurusanController.text,
                    nomorHp: nomorHpController.text,
                    semester: semesterController.text,
                  );

                  // Validasi response update
                  if (updatedData != null) {
                    setState(() {
                      userData = {
                        'nama':
                            updatedData['name']?.toString() ??
                            namaController.text,
                        'nim':
                            updatedData['nim']?.toString() ??
                            nimController.text,
                        'status': 'Mahasiswa Aktif',
                        'jurusan':
                            updatedData['jurusan']?.toString() ??
                            jurusanController.text,
                        'email':
                            updatedData['email']?.toString() ??
                            userData?['email'],
                        'nomor_hp':
                            updatedData['no_hp']?.toString() ??
                            nomorHpController.text,
                        'semester':
                            updatedData['semester']?.toString() ??
                            semesterController.text,
                        'photoPath': userData?['photoPath'],
                        'organisasi': userData?['organisasi'] ?? [],
                      };
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profil berhasil diperbarui')),
                    );
                  } else {
                    throw Exception('Response update tidak valid');
                  }
                } catch (e) {
                  print('Update error: $e');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              isLoading
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Memuat profil...',
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ],
                    ),
                  )
                  : errorMessage != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Gagal memuat profil',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errorMessage!,
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _fetchUserProfile,
                          icon: Icon(Icons.refresh),
                          label: Text('Coba Lagi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  )
                  : userData == null
                  ? Center(
                    child: Text(
                      'Data profil tidak tersedia',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  )
                  : SingleChildScrollView(
                    child: Column(
                      children: [
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(24, 30, 24, 40),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFF1E3A8A).withOpacity(0.9),
                                  Color(0xFF3B82F6),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: GestureDetector(
                                    onTap: _pickAndUploadPhoto,
                                    child: ClipOval(
                                      child:
                                          userData?['photoPath'] != null
                                              ? Image.network(
                                                userData!['photoPath']!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color: Color(
                                                        0xFF3B82F6,
                                                      ).withOpacity(0.1),
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 60,
                                                        color: Color(
                                                          0xFF3B82F6,
                                                        ),
                                                      ),
                                                    ),
                                              )
                                              : Container(
                                                color: Color(
                                                  0xFF3B82F6,
                                                ).withOpacity(0.1),
                                                child: Icon(
                                                  Icons.person,
                                                  size: 60,
                                                  color: Color(0xFF3B82F6),
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Text(
                                  userData?['nama'] ?? 'Nama Tidak Tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Text(
                                    userData?['status'] ??
                                        'Status Tidak Tersedia',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            constraints: BoxConstraints(
                              minHeight:
                                  MediaQuery.of(context).size.height - 320,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF8F9FA).withOpacity(0.9),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  Text(
                                    'Informasi Pribadi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  _buildInfoCard(
                                    icon: Icons.badge_outlined,
                                    title: 'NIM',
                                    subtitle:
                                        userData?['nim'] ??
                                        'NIM Tidak Tersedia',
                                    color: Color(0xFF3B82F6),
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoCard(
                                    icon: Icons.school_outlined,
                                    title: 'Jurusan',
                                    subtitle:
                                        userData?['jurusan'] ??
                                        'Jurusan Tidak Tersedia',
                                    color: Color(0xFF1E3A8A),
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoCard(
                                    icon: Icons.class_outlined,
                                    title: 'Semester',
                                    subtitle:
                                        userData?['semester'] ??
                                        'Semester Tidak Tersedia',
                                    color: Color(0xFF4A90E2),
                                  ),
                                  SizedBox(height: 40),
                                  Text(
                                    'Organisasi Diikuti',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ...(userData?['organisasi'] != null &&
                                          (userData!['organisasi'] as List)
                                              .isNotEmpty
                                      ? (userData!['organisasi'] as List)
                                          .map<Widget>((org) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 16.0,
                                              ),
                                              child: _buildInfoCard(
                                                icon: Icons.groups_outlined,
                                                title:
                                                    org['nama']?.toString() ??
                                                    'Organisasi',
                                                subtitle:
                                                    org['pivot']?['role']
                                                        ?.toString() ??
                                                    'Anggota',
                                                color: Color(0xFF3B82F6),
                                              ),
                                            );
                                          })
                                          .toList()
                                      : [
                                        Container(
                                          padding: EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Text(
                                            'Belum mengikuti organisasi',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ]),
                                  SizedBox(height: 16),
                                  Text(
                                    'Informasi Akun',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2C3E50),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoCard(
                                    icon: Icons.email_outlined,
                                    title: 'Email',
                                    subtitle:
                                        userData?['email'] ??
                                        'Email Tidak Tersedia',
                                    color: Color(0xFF60A5FA),
                                  ),
                                  SizedBox(height: 16),
                                  _buildInfoCard(
                                    icon: Icons.phone_outlined,
                                    title: 'No. Handphone',
                                    subtitle:
                                        userData?['nomor_hp'] ??
                                        'Nomor Telepon Tidak Tersedia',
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _showEditProfileDialog,
                                          icon: Icon(Icons.edit, size: 20),
                                          label: Text('Edit Profil'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFF3B82F6),
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Settings coming soon!',
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.settings, size: 20),
                                          label: Text('Pengaturan'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Color(0xFF4A90E2),
                                            padding: EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            side: BorderSide(
                                              color: Color(0xFF4A90E2),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Color(0xFF2C3E50),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
