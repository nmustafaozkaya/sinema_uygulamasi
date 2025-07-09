import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/screens/home.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  final rememberMe = await UserPreferences.getRememberMe();
  final currentUser = rememberMe ? await UserPreferences.readData() : null;

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
