import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart'; // User sınıfının olduğu varsayılıyor
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // FontAwesome ikonları için
import 'package:sinema_uygulamasi/screens/cinema_screen.dart'; // Sinema ekranınız
import 'package:sinema_uygulamasi/screens/profile_screen.dart'; // Profil ekranınız
import 'package:sinema_uygulamasi/screens/home_screen.dart'; // Ana ekranınız (import yolu düzeltildi)

class HomePage extends StatefulWidget {
  final User currentUser;

  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

int aktifOge = 0;

Widget gecerliSayfa(int aktif, User user) {
  switch (aktif) {
    case 0:
      return HomeScreen(currentUser: user);
    case 1:
      return CinemaScreen();
    case 2:
      return ProfileScreen(currentUser: user);
    default:
      return HomeScreen(currentUser: user);
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: gecerliSayfa(aktifOge, widget.currentUser),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: aktifOge,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.theaters), label: 'Cinemas'),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.solidUser),
            label: 'Profile',
          ),
        ],
        onTap: (int index) {
          setState(() {
            aktifOge = index;
          });
        },
      ),
    );
  }
}
