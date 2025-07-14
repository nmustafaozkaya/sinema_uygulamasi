import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/cinema_screen.dart';
import 'package:sinema_uygulamasi/screens/movies_screen.dart';
import 'package:sinema_uygulamasi/screens/profile_screen.dart';
import 'package:sinema_uygulamasi/screens/home_screen.dart';

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
      return HomeScreen();
    case 1:
      return moviesScreen(isComingSoon: false);
    case 2:
      return CinemaScreen();
    case 3:
      return ProfileScreen(currentUser: user);
    default:
      return HomeScreen();
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
        selectedItemColor: AppColorStyle.primaryAccent,
        unselectedItemColor: AppColorStyle.textPrimary,
        backgroundColor: AppColorStyle.appBarColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Movies'),
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
