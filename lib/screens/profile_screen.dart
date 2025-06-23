import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/components/user_preferences.dart';
import 'package:sinema_uygulamasi/screens/login_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.currentUser});
  final User currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: AppTextStyle.TOP_HEADER_),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.0,
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
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        FontAwesomeIcons.user,
                        size: 60,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.userName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentUser.userEmail,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Account Settings',
              style: AppTextStyle.MIDDLE_BOLD_HEADER,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blueAccent),
              title: const Text('Edit Information'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit information page coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.lock,
                color: Colors.blueAccent,
              ),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password change page coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.creditCard,
                color: Colors.blueAccent,
              ),
              title: const Text('Payment Methods'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment methods page coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text('My Movies', style: AppTextStyle.MIDDLE_BOLD_HEADER),
            const Divider(),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.film,
                color: Colors.blueAccent,
              ),
              title: const Text('View All Movies'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All movies page coming soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: const Text('Favorite Movies'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Favorite movies page coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            const Text('My Tickets', style: AppTextStyle.MIDDLE_BOLD_HEADER),
            const Divider(),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.ticketSimple,
                color: Colors.blueAccent,
              ),
              title: const Text('Past Tickets'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Past tickets page coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                FontAwesomeIcons.calendarCheck,
                color: Colors.blueAccent,
              ),
              title: const Text('Upcoming Tickets'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upcoming tickets page coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await RememberUserPrefs.removeUserInfo();

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
