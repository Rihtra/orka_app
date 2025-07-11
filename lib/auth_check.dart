import 'package:flutter/material.dart';
import 'services/local_storage.dart';
import 'login.dart'; // Ganti dengan path ke halaman login kamu
import 'home_page.dart'; // Ganti dengan path ke halaman beranda kamu

class AuthCheck extends StatelessWidget {
  const AuthCheck({Key? key}) : super(key: key);

  Future<bool> _isLoggedIn() async {
    final token = await LocalStorage.getToken();
    return token != null; // True kalau token ada, false kalau nggak ada
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Tampilkan loading screen sambil cek token
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          // Kalau ada token, arahkan ke halaman beranda
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/home');
          });
        } else {
          // Kalau nggak ada token, arahkan ke halaman login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }

        // Tampilkan placeholder selama redirect
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}