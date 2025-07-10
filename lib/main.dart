import 'package:flutter/material.dart';
import 'package:multiplatform/status_pendaftaran.dart';
import 'login.dart';
import 'home_page.dart';
import 'register.dart'; // Untuk RegisterPage (pendaftaran akun)
import 'profile_user.dart'; // Unt

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemilihan UKM',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(), // Halaman awal adalah LoginPage
      routes: {
        '/home': (context) => HomePage(), // Rute ke HomePage
        '/register': (context) => RegisterPage(), // Rute ke RegisterPage untuk registrasi akun
        '/profile': (context) => ProfileUserPage(),
        '/cek_status' :(context) => CekStatus(),
        // RegistrationPage akan diakses dari DetailPage, tidak perlu rute terpisah di sini
      },
      debugShowCheckedModeBanner: false,
    );
  }
}