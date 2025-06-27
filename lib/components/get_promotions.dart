import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinema_uygulamasi/components/promotions_screen.dart';

class Promotion {
  final String title;
  final String description;
  final String imagePath;
  final Color backgroundColor;

  Promotion({
    required this.title,
    required this.description,
    required this.imagePath,
    this.backgroundColor = Colors.blueGrey,
  });
}

Future<List<Promotion>> fetchPromotions() async {
  final prefs = await SharedPreferences.getInstance();
  final bool hasPurchased = prefs.getBool('hasPurchasedTicket') ?? false;

  List<Promotion> promotions = [];

  if (!hasPurchased) {
    promotions.add(
      Promotion(
        title: 'İlk Bilete Özel %30 İndirim!',
        description: 'İlk biletinizde anında %30 indirim kazanın.',
        imagePath: 'assets/images/promotion_firstbuy.png',
        backgroundColor: const Color(0xffd94d43),
      ),
    );
  }

  promotions.add(
    Promotion(
      title: 'Mısır ve İçecek Menüsü',
      description: 'Büyük boy mısır ve içecek sadece 200 TL.',
      imagePath: 'assets/images/popcorn_coke.png',
      backgroundColor: const Color(0xff3a8c8c),
    ),
  );

  promotions.add(
    Promotion(
      title: 'Çarşamba Günü Halk Günü!',
      description: 'Her Çarşamba tüm seanslar tek fiyat.',
      imagePath: 'assets/images/cinema_woman.png',
      backgroundColor: const Color(0xffa168a3),
    ),
  );

  return promotions;
}

class HorizontalPromotionCard extends StatelessWidget {
  final Promotion promotion;
  const HorizontalPromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PromotionsScreen()),
        );
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: promotion.backgroundColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                promotion.imagePath,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: Colors.grey[800],
                    child: const Center(
                      child: Icon(
                        Icons.campaign,
                        color: Colors.white54,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      promotion.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
