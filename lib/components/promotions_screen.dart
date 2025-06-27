import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sinema_uygulamasi/components/get_promotions.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  final List<Promotion> _promotions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  Future<void> _loadPromotions() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasPurchased = prefs.getBool('hasPurchasedTicket') ?? false;

    List<Promotion> loadedPromotions = [];

    if (!hasPurchased) {
      loadedPromotions.add(
        Promotion(
          title: 'İlk Bilete Özel %30 İndirim!',
          description:
              'Uygulamamızdan alacağınız ilk sinema biletinde anında %30 indirim kazanın. Bu fırsatı kaçırmayın!',
          imagePath: 'assets/images/promotion_firstbuy.png',
          backgroundColor: const Color(0xffd94d43),
        ),
      );
    }

    loadedPromotions.add(
      Promotion(
        title: 'Mısır ve İçecek Menüsü 200 TL',
        description:
            'Büyük boy patlamış mısır ve orta boy içecek sadece 200 TL. Biletinize eklemeyi unutmayın.',
        imagePath: 'assets/images/popcorn_coke.png',
        backgroundColor: const Color(0xff3a8c8c),
      ),
    );

    loadedPromotions.add(
      Promotion(
        title: 'Çarşamba Günü Halk Günü!',
        description:
            'Her Çarşamba tüm seanslar tek fiyat. İndirimli biletlerle sinema keyfini yaşayın.',
        imagePath: 'assets/images/cinema_woman.png',
        backgroundColor: const Color(0xffa168a3),
      ),
    );

    // State'i güncelle ve arayüzü yeniden çiz
    setState(() {
      _promotions.addAll(loadedPromotions);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Promosyonlar',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ) // Yükleniyorsa bekleme animasyonu göster
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _promotions.length,
              itemBuilder: (context, index) {
                final promotion = _promotions[index];
                return PromotionCard(
                  promotion: promotion,
                ); // Her promosyon için bir kart oluştur
              },
            ),
    );
  }
}

// Promosyonları daha şık göstermek için ayrı bir Widget
class PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const PromotionCard({super.key, required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: promotion.backgroundColor,
      elevation: 8.0,
      margin: const EdgeInsets.only(bottom: 20.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.asset(
              promotion.imagePath,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              // Resim bulunamazsa hata vermemesi için
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.movie, color: Colors.white54, size: 50),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promotion.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  promotion.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Kullan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
