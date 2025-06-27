import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movie_preferences.dart';
import 'package:sinema_uygulamasi/components/movies.dart';

// Class adını isteğin üzerine 'buyScreen' olarak güncelledim.
class buyScreen extends StatefulWidget {
  final Movie? currentMovie;
  const buyScreen({super.key, this.currentMovie});

  @override
  State<buyScreen> createState() => _buyScreenState();
}

class _buyScreenState extends State<buyScreen> {
  // Bu değişken, SharedPreferences'tan sinema bilgisini yükledikten sonra dolacak.
  Cinema? currentCinema;

  @override
  void initState() {
    super.initState();
    // Sayfa ilk açıldığında hafızadaki sinema bilgisini yükle.
    _loadCinema();
  }

  // RememberMoviePrefs kullanarak kaydedilmiş sinemayı getiren fonksiyon.
  void _loadCinema() async {
    Cinema? cinema = await RememberMoviePrefs.getRememberMovie();
    // setState çağırarak arayüzün güncellenmesini sağlıyoruz.
    setState(() {
      currentCinema = cinema;
    });
  }

  // Afişi gösteren widget (Hata durumunu yönetir).
  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: Colors.grey.shade400,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          posterUrl,
          width: 120,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.broken_image_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            );
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme Ekranı'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                movie != null
                    ? buildMoviePoster(movie.poster)
                    : const SizedBox.shrink(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Film Başlığı
                      Text(
                        movie?.title ?? 'Film Adı Yükleniyor...',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text('Tür: ${movie?.genre ?? '...'}'),
                      const SizedBox(height: 4),
                      Text('Süre: ${movie?.runtime ?? '...'}'),
                      const SizedBox(height: 4),
                      Text('Tarih: ${movie?.released ?? '...'}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Column(
              children: [
                if (currentCinema != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              currentCinema!.cinemaName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 22.0),
                        child: Text(
                          currentCinema!.cinemaAddress,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text("Sinema bilgisi yükleniyor..."),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
