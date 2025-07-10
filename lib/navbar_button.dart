import 'package:flutter/material.dart';
import 'home_page.dart';
import 'status_pendaftaran.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Background putih
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Color(0xFF1E3A8A), // Ikon biru saat dipilih
        unselectedItemColor: Color(
          0xFF1E3A8A,
        ).withOpacity(0.6), // Ikon biru dengan opacity saat tidak dipilih
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A),
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: Color(0xFF1E3A8A).withOpacity(0.6),
        ),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline, size: 24),
            label: 'Cek Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
