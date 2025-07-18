import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/my_ticket_screen.dart';

class ProfileScreen extends StatelessWidget {
  final User currentUser;
  const ProfileScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorStyle.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(
            color: AppColorStyle.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorStyle.appBarColor,
        centerTitle: true,
        elevation: 0.0,
        iconTheme: const IconThemeData(color: AppColorStyle.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: AppColorStyle.appBarColor,
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColorStyle.primaryAccent,
                      child: const Icon(
                        // const ekledik
                        FontAwesomeIcons.user,
                        size: 50,
                        color: AppColorStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColorStyle.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser.email,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColorStyle.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Hesap Ayarları',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),

            ListTile(
              leading: const Icon(
                Icons.edit,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Bilgilerini Düzenle',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                // SnackBar'ı düzeltildi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Bilgilerimi Düzenle yakında gelecek"),
                    duration: Duration(seconds: 2), // Kısa gösterim süresi
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.lock,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Şifreni Değiştir',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Şifre Değiştirme yakında gelecek"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.creditCard,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Ödeme Yöntemleri',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Ödeme Yöntemleri yakında gelecek"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Filmlerim',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),

            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text(
                'Favori Filmler',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Favori Filmler yakında gelecek"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text(
              'Biletlerim',
              style: TextStyle(
                color: AppColorStyle.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const Divider(color: AppColorStyle.primaryAccent),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.ticketSimple,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Geçmiş Biletler',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyTicketsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.calendarCheck,
                color: AppColorStyle.secondaryAccent,
              ),
              title: const Text(
                'Gelecek Biletler',
                style: TextStyle(color: AppColorStyle.textPrimary),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: AppColorStyle.textSecondary,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Gelecek Biletler yakında gelecek"),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Çıkış Yap',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () async {
                await UserPreferences.removeData();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
