import 'package:flutter/material.dart';
import 'dart:async';
import 'detail_page.dart';
import 'navbar_button.dart';
import 'models/organisasi_model.dart';
import 'services/organisasi_service.dart';
import '/services/local_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UKM {
  final int? id;
  final String name;
  final String category;
  final String description;
  final String fullDescription;
  final String requirements;
  final String visi;
  final String misi;
  final String contact;
  final String meetingTime;
  final IconData icon;
  final Color color;
  final String logoPath;
  final String photoPath;
  final Map<String, dynamic>? struktur;
  final int? jumlahAnggota;
  final List<DivisiModel>? divisis;

  UKM({
    this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.fullDescription,
    required this.requirements,
    required this.visi,
    required this.misi,
    required this.contact,
    required this.meetingTime,
    required this.icon,
    required this.color,
    required this.logoPath,
    required this.photoPath,
    this.struktur,
    this.jumlahAnggota,
    this.divisis,
  });

  // Factory method untuk convert dari OrganisasiModel
  factory UKM.fromOrganisasiModel(OrganisasiModel organisasi) {
    print('Logo URL dari OrganisasiModel: ${organisasi.logoUrl}');
    return UKM(
      id: organisasi.id,
      name: organisasi.nama,
      category: _mapTipeToCategory(organisasi.tipe ?? 'Organisasi'),
      description: organisasi.deskripsi ?? 'Tidak ada deskripsi',
      fullDescription: '''
${organisasi.deskripsi ?? 'Tidak ada deskripsi'}

// Visi:
// ${organisasi.visi ?? 'Tidak ada visi'}

// Misi:
// ${organisasi.misi ?? 'Tidak ada misi'}
      ''',
      visi: organisasi.visi ?? 'Tidak ada Visi',
      misi: organisasi.misi ?? 'Tidak ada Misi',
      requirements: organisasi.syarat ?? 'Tidak ada syarat khusus',
      contact:
          'Email: ${organisasi.adminUser?.email ?? 'Tidak tersedia'}\nAdmin: ${organisasi.adminUser?.name ?? 'Tidak tersedia'}',
      meetingTime: 'Informasi pertemuan akan diumumkan',
      icon: _getIconForCategory(organisasi.tipe ?? 'Organisasi'),
      color: _getColorForCategory(organisasi.tipe ?? 'Organisasi'),
      logoPath: organisasi.logoUrl ?? 'images/polbeng_logo.png',
      photoPath: 'images/default_photo.jpg',
      struktur: organisasi.struktur,
      jumlahAnggota: organisasi.jumlahAnggota,
      divisis: organisasi.divisis,
    );
  }

  static String _mapTipeToCategory(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'himpunan':
        return 'Himpunan';
      case 'organisasi keagamaan':
        return 'Organisasi Keagamaan';
      case 'olahraga':
        return 'Olahraga';
      case 'seni & budaya':
        return 'Seni & Budaya';
      case 'akademik':
        return 'Akademik';
      default:
        return 'Organisasi';
    }
  }

  static IconData _getIconForCategory(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'himpunan':
        return Icons.computer;
      case 'organisasi keagamaan':
        return Icons.mosque;
      case 'olahraga':
        return Icons.sports_soccer;
      case 'seni & budaya':
        return Icons.music_note;
      case 'akademik':
        return Icons.language;
      default:
        return Icons.group;
    }
  }

  static Color _getColorForCategory(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'himpunan':
        return Color(0xFF3B82F6);
      case 'organisasi keagamaan':
        return Color(0xFF2563EB);
      case 'olahraga':
        return Color(0xFF2563EB);
      case 'seni & budaya':
        return Color(0xFF3B82F6);
      case 'akademik':
        return Color(0xFF1E40AF);
      default:
        return Color(0xFF6B7280);
    }
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedCategory = 'Semua';
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final PageController _photoPageController = PageController();
  Timer? _photoTimer;
  int _currentPhotoIndex = 0;
  int _selectedIndex = 0;

  // API related variables
  List<OrganisasiModel> _organisasiList = [];
  List<UKM> _ukmList = [];
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> categories = [
    'Semua',
    'Himpunan',
    'Organisasi Keagamaan',
    'Olahraga',
    'Seni & Budaya',
    'Akademik',
    'Organisasi',
  ];

  List<UKM> get filteredUKM {
    return selectedCategory == 'Semua'
        ? _ukmList
        : _ukmList.where((ukm) => ukm.category == selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOrganisasiData();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  Future<void> _loadOrganisasiData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Ambil token dari LocalStorage
      final token = await LocalStorage.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Token autentikasi tidak ditemukan';
          _isLoading = false;
        });
        return; // Hentikan jika token tidak ada
      }

      final organisasiList = await OrganisasiService.fetchAllOrganisasi(token);
      setState(() {
        _organisasiList = organisasiList;
        _ukmList =
            organisasiList.map((org) => UKM.fromOrganisasiModel(org)).toList();
        _isLoading = false;
      });

      if (_ukmList.isNotEmpty) {
        _startPhotoSlider();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data organisasi: $e';
        _isLoading = false;
      });
    }
  }

  void _startPhotoSlider() {
    _photoTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_ukmList.isEmpty) return;

      if (_currentPhotoIndex < _ukmList.length - 1) {
        _currentPhotoIndex++;
      } else {
        _currentPhotoIndex = 0;
      }

      if (_photoPageController.hasClients) {
        _photoPageController.animateToPage(
          _currentPhotoIndex,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex)
      return; // Prevent re-navigation to the same page
    setState(() {
      _selectedIndex = index;
    });
    // Navigate to the corresponding route
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

  Future<void> _refreshData() async {
    await _loadOrganisasiData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _photoTimer?.cancel();
    _photoPageController.dispose();
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
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Premium App Bar
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'images/orkanobg.png',
                            height: 28,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORKA Polbeng',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Wujudkan Potensi Terbaikmu',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content based on loading state
                  if (_isLoading)
                    _buildLoadingWidget()
                  else if (_errorMessage != null)
                    _buildErrorWidget()
                  else
                    _buildMainContent(),
                ],
              ),
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

  Widget _buildLoadingWidget() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              'Memuat data organisasi...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Color(0xFF1E3A8A),
              ),
              child: Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        // Auto-Sliding Organization Photos
        if (_ukmList.isNotEmpty) ...[
          Container(
            height: 200,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: PageView.builder(
                    controller: _photoPageController,
                    itemCount: _ukmList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPhotoIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final ukm = _ukmList[index];
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                ukm.logoPath.startsWith('http')
                                    ? NetworkImage(ukm.logoPath)
                                    : AssetImage(ukm.logoPath)
                                        as ImageProvider,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.3),
                              BlendMode.darken,
                            ),
                            onError: (exception, stackTrace) {
                              print(
                                'Error loading photo: ${ukm.logoPath}, error: $exception',
                              ); // Debug
                            },
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ukm.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                ukm.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: ukm.color.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  ukm.category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Photo Indicators
          Container(
            margin: EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _ukmList.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPhotoIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color:
                        _currentPhotoIndex == index
                            ? Colors.white
                            : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 20),
        ],

        // Enhanced Category Filter
        Container(
          height: 50,
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory == category;
              return Padding(
                padding: EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? LinearGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.95),
                                ],
                              )
                              : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 5),
                                ),
                              ]
                              : [],
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Color(0xFF1E3A8A) : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16),

        // Premium UKM List
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF8FAFC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 16),
                child:
                    filteredUKM.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredUKM.length,
                          itemBuilder: (context, index) {
                            final ukm = filteredUKM[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => DetailPage(ukm: ukm),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 20,
                                          offset: Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                ukm.color.withOpacity(0.2),
                                                ukm.color.withOpacity(0.1),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                          ),
                                          child: Center(
                                            child:
                                                ukm.logoPath.startsWith('http')
                                                    ? CachedNetworkImage(
                                                      imageUrl: ukm.logoPath,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (context, url) =>
                                                              CircularProgressIndicator(),
                                                      errorWidget: (
                                                        context,
                                                        url,
                                                        error,
                                                      ) {
                                                        print(
                                                          'Error loading logo: $url, error: $error',
                                                        ); // Debug
                                                        return Icon(
                                                          ukm.icon,
                                                          color: ukm.color,
                                                          size: 30,
                                                        );
                                                      },
                                                    )
                                                    : Image.asset(
                                                      ukm.logoPath,
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        print(
                                                          'Error loading asset: ${ukm.logoPath}, error: $error',
                                                        ); // Debug
                                                        return Icon(
                                                          ukm.icon,
                                                          color: ukm.color,
                                                          size: 30,
                                                        );
                                                      },
                                                    ),
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                ukm.name,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                              Text(
                                                ukm.description,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF64748B),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: ukm.color
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      ukm.category,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: ukm.color,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Spacer(),
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: ukm.color
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: ukm.color,
                                                      size: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48, color: Color(0xFF64748B)),
            SizedBox(height: 16),
            Text(
              'Tidak ada organisasi ditemukan',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coba ganti kategori atau refresh halaman',
              style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }
}
