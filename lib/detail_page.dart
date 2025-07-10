import 'package:flutter/material.dart';
import 'home_page.dart'; // Untuk kelas UKM
import 'pendaftaran_ukm.dart'; // Untuk RegistrationPage (pendaftaran organisasi)

class DetailPage extends StatefulWidget {
  final UKM ukm;

  const DetailPage({Key? key, required this.ukm}) : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Widget untuk Divisi dengan chip-based layout
  Widget _buildDivisiSection() {
    final divisis = widget.ukm.divisis ?? [];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF059669).withOpacity(0.1), Color(0xFF059669).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF059669).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.groups, color: Color(0xFF059669), size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Divisi & Bidang Kerja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content: Chip-based divisi
          Padding(
            padding: EdgeInsets.all(20),
            child: divisis.isEmpty
                ? Text(
                    'Tidak ada data divisi.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.6,
                    ),
                  )
                : Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: divisis.map((divisi) => GestureDetector(
                      onTap: () {
                        // Bisa tambah aksi, misal buka detail divisi
                      },
                      child: Chip(
                        label: Text(
                          divisi.nama,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        backgroundColor: Color(0xFFF1F5F9),
                        elevation: 2,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xFF059669).withOpacity(0.2)),
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Struktur Organisasi dengan ListTile-based layout
  Widget _buildStrukturSection() {
    final struktur = widget.ukm.struktur ?? {};
    final List<Map<String, dynamic>> roles = [
      {'key': 'ketua', 'label': 'Ketua', 'icon': Icons.star},
      {'key': 'wakil', 'label': 'Wakil Ketua', 'icon': Icons.star_border},
      {'key': 'sekretaris', 'label': 'Sekretaris', 'icon': Icons.description},
      {'key': 'bendahara', 'label': 'Bendahara', 'icon': Icons.account_balance_wallet},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9333EA).withOpacity(0.1), Color(0xFF9333EA).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF9333EA).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.account_tree_outlined, color: Color(0xFF9333EA), size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Struktur Organisasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content: ListTile-based struktur
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: roles.map((role) {
                final name = struktur[role['key'] as String] ?? '-';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(0xFF9333EA).withOpacity(0.1),
                    child: Icon(role['icon'] as IconData, color: Color(0xFF9333EA), size: 20),
                  ),
                  title: Text(
                    role['label'] as String,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  subtitle: Text(
                    name,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk Jumlah Anggota dengan badge effect
  Widget _buildJumlahAnggotaSection() {
    final jumlah = widget.ukm.jumlahAnggota ?? 0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEC4899).withOpacity(0.1), Color(0xFFEC4899).withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFFEC4899).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.people_alt_outlined, color: Color(0xFFEC4899), size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Jumlah Anggota',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content: Badge effect
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEC4899).withOpacity(0.1),
                    border: Border.all(color: Color(0xFFEC4899).withOpacity(0.3)),
                  ),
                  child: Icon(Icons.people, color: Color(0xFFEC4899), size: 30),
                ),
                SizedBox(width: 12),
                Text(
                  '$jumlah Anggota',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEC4899),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('UKM Data: ${widget.ukm.divisis}, ${widget.ukm.struktur}, ${widget.ukm.jumlahAnggota}'); // Debug
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
          child: Column(
            children: [
              // Premium Header dengan gradient
              Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  children: [
                    // App bar dengan back button
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Detail ${widget.ukm.name}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Icon(
                            Icons.bookmark_border,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24),

                    // Premium Logo dan Info Card
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Logo dengan efek glassmorphism
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  child: widget.ukm.logoPath.startsWith('http')
    ? Image.network(
        widget.ukm.logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading logo URL: ${widget.ukm.logoPath}, error: $error'); // Debug
          return Icon(
            widget.ukm.icon,
            color: widget.ukm.color,
            size: 40,
          );
        },
      )
    : Image.asset(
        widget.ukm.logoPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          print('Error loading logo asset: ${widget.ukm.logoPath}, error: $error'); // Debug
          return Icon(
            widget.ukm.icon,
            color: widget.ukm.color,
            size: 40,
          );
        },
      ),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ukm.name,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      widget.ukm.category,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    widget.ukm.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content area dengan background putih
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Handle indicator
                        Container(
                          margin: EdgeInsets.only(top: 12),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Deskripsi
                                _buildPremiumSection(
                                  title: 'Tentang ${widget.ukm.name}',
                                  content: _getDescription(widget.ukm.description),
                                  icon: Icons.info_outline,
                                  color: Color(0xFF3B82F6),
                                ),
                                SizedBox(height: 20),
                                // Divisi
                                _buildDivisiSection(),
                                SizedBox(height: 20),
                                // Struktur
                                _buildStrukturSection(),
                                SizedBox(height: 20),
                                // Jumlah Anggota
                                _buildJumlahAnggotaSection(),
                                SizedBox(height: 20),
                                // Visi Misi
                                _buildPremiumVisiMisiSection(widget.ukm.name),
                                SizedBox(height: 20),
                                // Info Grid
                                _buildInfoGrid(),
                                SizedBox(height: 24),
                                // CTA Button
                                _buildPremiumCTAButton(),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header section
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumVisiMisiSection(String ukmName) {
    final visiMisi = _getVisiMisi(ukmName);
    final parts = visiMisi.split('\n\nMISI:');
    final visi = parts[0].replaceFirst('VISI:\n', '');
    final misi = parts.length > 1 ? parts[1] : '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7C3AED).withOpacity(0.1),
                  Color(0xFF7C3AED).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Color(0xFF7C3AED).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    Icons.visibility,
                    color: Color(0xFF7C3AED),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  'Visi & Misi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(0xFF7C3AED).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.visibility,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'VISI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.ukm.visi,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Color(0xFF7C3AED).withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.flag,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'MISI',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Text(
                          widget.ukm.misi,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPremiumInfoCard(
                'Syarat Pendaftaran',
                widget.ukm.requirements,
                Icons.assignment_turned_in,
                Color(0xFF059669),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildPremiumInfoCard(
                'Jadwal Kegiatan',
                widget.ukm.meetingTime,
                Icons.schedule,
                Color(0xFFDC2626),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildPremiumInfoCard(
          'Kontak & Informasi',
          widget.ukm.contact,
          Icons.phone,
          Color(0xFFEA580C),
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildPremiumInfoCard(
    String title,
    String content,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCTAButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            try {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrationPage(ukm: widget.ukm),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Error: $e')));
            }
          },
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Daftar Sekarang',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getDescription(String ukmName) {
    switch (ukmName) {
      case 'HIMTI':
        return 'Himpunan Mahasiswa Teknik Informatika (HIMTI) adalah organisasi mahasiswa yang berfokus pada pengembangan teknologi informasi dan komputer. Kami berkomitmen untuk menciptakan lingkungan belajar yang inovatif dan kolaboratif bagi seluruh mahasiswa TI di Politeknik Bengkalis.';
      case 'HIMSIS':
        return 'Himpunan Mahasiswa Sistem Informasi (HIMSIS) adalah wadah bagi mahasiswa untuk mengembangkan kemampuan dalam bidang sistem informasi dan teknologi bisnis. Kami mengintegrasikan teknologi dengan kebutuhan bisnis modern.';
      case 'LDK Al-Islam':
        return 'Lembaga Dakwah Kampus Al-Islam adalah organisasi keagamaan yang bergerak dalam bidang dakwah dan pengembangan spiritualitas Islam di lingkungan kampus. Kami mengajak mahasiswa untuk mendalami nilai-nilai Islam dalam kehidupan sehari-hari.';
      case 'Persekutuan Kristen':
        return 'Persekutuan Kristen adalah komunitas rohani yang menyediakan ruang bagi mahasiswa Kristen untuk bertumbuh dalam iman dan melayani sesama. Kami mengadakan ibadah, diskusi, dan kegiatan pelayanan sosial.';
      case 'Futsal Club':
        return 'Futsal Club Politeknik Bengkalis adalah organisasi olahraga yang menaungi mahasiswa yang memiliki passion dalam olahraga futsal. Kami mengembangkan bakat, prestasi, dan sportivitas melalui latihan dan kompetisi.';
      case 'Paduan Suara':
        return 'Paduan Suara Politeknik Bengkalis adalah kelompok seni musik vokal yang mengembangkan kemampuan bernyanyi dan apresiasi seni musik. Kami tampil dalam berbagai acara kampus dan kompetisi musik.';
      case 'English Club':
        return 'English Club adalah organisasi yang berfokus pada pengembangan kemampuan berbahasa Inggris mahasiswa. Kami mengadakan berbagai kegiatan untuk meningkatkan speaking, writing, dan communication skills.';
      default:
        return 'Organisasi mahasiswa yang berkomitmen untuk mengembangkan potensi dan bakat mahasiswa di bidangnya masing-masing.';
    }
  }

  String _getVisiMisi(String ukmName) {
    switch (ukmName) {
      case 'HIMTI':
        return 'VISI:\nMenjadi organisasi mahasiswa IT terdepan yang menghasilkan lulusan berkompeten dan berintegritas.\n\nMISI:\nMengembangkan hard skill dan soft skill mahasiswa TI, menciptakan inovasi teknologi yang bermanfaat, membangun networking dengan industri IT, dan menjadi wadah aktualisasi diri mahasiswa.';
      case 'HIMSIS':
        return 'VISI:\nMenjadi pusat excellence dalam pengembangan sistem informasi dan teknologi bisnis.\n\nMISI:\nMengintegrasikan teknologi dengan kebutuhan bisnis, menghasilkan sistem informasi yang inovatif, membangun kemitraan strategis dengan industri, dan mengembangkan entrepreneur mindset.';
      case 'LDK Al-Islam':
        return 'VISI:\nTerwujudnya generasi muslim yang beriman, bertaqwa, dan berkontribusi positif.\n\nMISI:\nMenyebarkan dakwah Islam dengan cara yang moderat, membina akhlaq dan karakter Islami, mengembangkan potensi umat melalui pendidikan, dan berkontribusi dalam pembangunan masyarakat.';
      case 'Persekutuan Kristen':
        return 'VISI:\nMenjadi komunitas Kristen yang dewasa dalam iman dan melayani dengan kasih.\n\nMISI:\nMembangun persekutuan yang kuat dalam Kristus, mengembangkan pelayanan yang berkualitas, menjadi berkat bagi komunitas kampus, dan mempersiapkan pemimpin rohani masa depan.';
      case 'Futsal Club':
        return 'VISI:\nMenjadi klub futsal terbaik dengan prestasi gemilang dan sportivitas tinggi.\n\nMISI:\nMengembangkan bakat dan prestasi futsal, menanamkan nilai-nilai sportivitas dan fair play, membangun tim yang solid dan kompak, dan mengharumkan nama Politeknik Bengkalis.';
      case 'Paduan Suara':
        return 'VISI:\nMenjadi paduan suara terdepan yang menginspirasi melalui harmoni musik.\n\nMISI:\nMengembangkan kemampuan vokal anggota, melestarikan dan mengembangkan seni musik, tampil dengan kualitas performance terbaik, dan membangun apresiasi seni di kampus.';
      case 'English Club':
        return 'VISI:\nMenjadi pusat pengembangan bahasa Inggris terbaik di lingkungan kampus.\n\nMISI:\nMeningkatkan kemampuan berbahasa Inggris mahasiswa, menyediakan program pembelajaran yang inovatif, memfasilitasi pertukaran budaya internasional, dan mempersiapkan mahasiswa untuk kompetisi global.';
      default:
        return 'VISI:\nMenjadi organisasi mahasiswa yang unggul dan berprestasi.\n\nMISI:\nMengembangkan potensi anggota, berkontribusi positif untuk kampus, dan membangun networking yang luas.';
    }
  }
}