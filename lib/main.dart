import 'package:flutter/material.dart';
// GEREKLİ IMPORT'U BURAYA EKLEYİN
import 'package:intl/date_symbol_data_local.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/screens/home.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';

void main() async {
  // Bu satırın var olduğundan emin olun
  WidgetsFlutterBinding.ensureInitialized();

  // GEREKLİ KODU BURAYA EKLEYİN
  // Bu, Türkçe tarih formatlama verilerini yükler.
  await initializeDateFormatting('tr_TR', null);

  // Mevcut kodunuz devam ediyor
  User? currentUser = await RememberUserPrefs.readUserInfo();

  runApp(MyApp(currentUser: currentUser));
}

class MyApp extends StatelessWidget {
  final User? currentUser;

  const MyApp({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sinema Uygulaması',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: currentUser != null
          ? HomePage(currentUser: currentUser!)
          : const LoginScreen(),
    );
  }
}
