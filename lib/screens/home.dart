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
  final int initialIndex;
  const HomePage({super.key, required this.currentUser, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

Widget gecerliSayfa(int aktif, User user) {
  switch (aktif) {
    case 0:
      return const HomeScreen();
    case 1:
      return const moviesScreen(isComingSoon: false);
    case 2:
      return const CinemaScreen();
    case 3:
      return ProfileScreen(currentUser: user);
    default:
      return const HomeScreen();
  }
}

class _HomePageState extends State<HomePage> {
  late int aktifOge;

  @override
  void initState() {
    super.initState();
    aktifOge = widget.initialIndex;
  }

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
