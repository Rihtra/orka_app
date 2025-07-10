import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'home_page.dart'; // Import kelas UKM
import 'services/pendaftaran_service.dart'; // Import service yang baru dibuat
import 'services/api_service.dart';
import 'services/local_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationPage extends StatefulWidget {
  final UKM ukm;

  const RegistrationPage({Key? key, required this.ukm}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _semesterController = TextEditingController();
  final _prodiController = TextEditingController();
  final _reasonController = TextEditingController();
  String? _selectedDivisi;
  String? _cvFileName;
  File? _cvFile;
  bool _isLoading = false;

  // Mapping divisi dengan ID (sesuaikan dengan database Anda)
  List<Map<String, dynamic>> _divisiOptions = [];

  @override
  void initState() {
    super.initState();
    _loadDivisiOptions(); // Ambil divisi berdasarkan UKM
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _whatsappController.dispose();
    _prodiController.dispose();
    _semesterController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _loadDivisiOptions() async {
    try {
      final token = await LocalStorage.getToken();
      print('Token in _loadDivisiOptions: $token'); // Debug
      if (token == null || token.isEmpty) {
        _showErrorSnackBar(
          'Token autentikasi tidak ditemukan. Silakan login kembali.',
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/organisasi/${widget.ukm.id}/divisi'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('Response Status: ${response.statusCode}'); // Debug
      print('Response Body: ${response.body}'); // Debug
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'] ?? [];
        setState(() {
          _divisiOptions =
              data.map((e) => {'id': e['id'], 'name': e['nama']}).toList();
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        _showErrorSnackBar('Sesi kadaluarsa. Silakan login kembali.');
        await LocalStorage.clearToken();
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showErrorSnackBar('Gagal memuat divisi: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in _loadDivisiOptions: $e'); // Debug
      _showErrorSnackBar('Error memuat divisi: $e');
    }
  }

  Future<void> _pickCV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _cvFileName = result.files.single.name;
          _cvFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showErrorDialog('Gagal memilih file: ${e.toString()}');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Text('Mengirim pendaftaran...'),
                ],
              ),
            ),
          ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _cvFile == null) {
      if (_cvFile == null) {
        _showErrorDialog('CV wajib diunggah');
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _showLoadingDialog();

    try {
      final result = await PendaftaranService.daftar(
        organisasiId: widget.ukm.id!,
        divisiId:
            _divisiOptions.firstWhere(
                  (div) => div['name'] == _selectedDivisi,
                )['id']
                as int,

        nama: _nameController.text,
        nim: _nimController.text,
        prodi: _prodiController.text,
        nomorWa: _whatsappController.text,
        semester: _semesterController.text,
        alasan: _reasonController.text,
        cvFile: _cvFile!,
      );

      // Tutup loading dialog
      Navigator.pop(context);

      if (result['success']) {
        _showSuccessDialog();
      } else {
        String errorMessage = result['message'];
        if (result['errors'] != null) {
          // Gabungkan semua error messages
          final errors = result['errors'] as Map<String, dynamic>;
          errorMessage += '\n';
          errors.forEach((key, value) {
            if (value is List) {
              errorMessage += '${value.join(', ')}\n';
            } else {
              errorMessage += '$value\n';
            }
          });
        }
        _showErrorDialog(errorMessage);
      }
    } catch (e) {
      // Tutup loading dialog
      Navigator.pop(context);
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Colors.white, Color(0xFFE6F0FA)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF10B981),
                  size: 50,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Pendaftaran Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Terima kasih ${_nameController.text}! Data Anda telah dikirim ke ${widget.ukm.name}. Tunggu konfirmasi lebih lanjut.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/home',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isMultiLine = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: isMultiLine ? 4 : 1,
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontFamily: 'Roboto'),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('images/polbeng_logo.png', height: 30),
            const SizedBox(width: 10),
            Text(
              'Pendaftaran ${widget.ukm.name}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
                fontSize: 20,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Formulir Pendaftaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _nimController,
                  label: 'NIM',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'NIM wajib diisi';
                    }
                    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                      return 'NIM harus 10 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _prodiController,
                  label: 'Prodi',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prodi wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _whatsappController,
                  label: 'Nomor WhatsApp',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor wajib diisi';
                    }
                    if (!RegExp(r'^\+?0[0-9]{9,}$').hasMatch(value)) {
                      return 'Masukkan nomor WhatsApp yang valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _semesterController,
                  label: 'Semester',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Semester wajib diisi';
                    }
                    final semester = int.tryParse(value);
                    if (semester == null || semester < 1 || semester > 8) {
                      return 'Semester harus antara 1-8';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _reasonController,
                  label: 'Alasan Bergabung',
                  isMultiLine: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Alasan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  label: 'Divisi yang Dipilih',
                  value: _selectedDivisi,
                  items:
                      _divisiOptions
                          .map((div) => div['name'] as String)
                          .toList(),
                  onChanged: (value) => setState(() => _selectedDivisi = value),
                  validator: (value) => value == null ? 'Pilih divisi' : null,
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Text(
                          _cvFileName ?? 'Belum ada CV yang dipilih',
                          style: TextStyle(
                            color:
                                _cvFileName == null
                                    ? Colors.grey
                                    : Colors.black87,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _pickCV,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                      ),
                      child: const Text(
                        'Upload CV',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_cvFileName == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'CV wajib diunggah (format PDF)',
                      style: TextStyle(
                        color: Colors.red[600],
                        fontSize: 12,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      disabledBackgroundColor: Colors.grey[400],
                    ),
                    child: Text(
                      _isLoading ? 'Mengirim...' : 'Kirim Pendaftaran',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
