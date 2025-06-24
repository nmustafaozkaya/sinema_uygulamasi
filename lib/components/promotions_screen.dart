import 'package:flutter/material.dart';

class Promotions extends StatelessWidget {
  const Promotions({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Promotions', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Görsel: tam genişlikte ve yükseklik ayarlanmış şekilde
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Image.asset('assets/images/seats.jpg', fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),
            const Text(
              'Promotions Page',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Here you can find the latest promotions and offers!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
