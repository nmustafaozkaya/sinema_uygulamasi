import 'package:flutter/material.dart';
import 'package:sinema_uygulamasi/components/auto_ImageSlider.dart';
import 'package:sinema_uygulamasi/components/user.dart';
import 'package:sinema_uygulamasi/constant/app_text_style.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/screens/movie_details.dart';

class HomeScreen extends StatelessWidget {
  final User currentUser;
  const HomeScreen({super.key, required this.currentUser});
  // HomeScreen sınıfının içine (build metodunun dışında, ancak sınıfın içinde)
  // Bu fonksiyonu çağırırken buildMoviePoster fonksiyonunu da parametre olarak geçmelisiniz
  // veya buildMoviePoster fonksiyonu da bu sınıfın bir metodu olmalı.

  // Önceki kodunuzdaki buildMoviePoster fonksiyonunu buraya taşıdığınızı varsayıyorum.
  // Eğer buildMoviePoster farklı bir yerde ise, onu da buraya taşımalı veya parametre olarak almalısınız.
  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return SizedBox.shrink(); // Daha iyi bir placeholder ikon/widget olabilir
    } else {
      return Image.network(
        posterUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print('Resim yüklenemedi: $posterUrl - Hata: $error');
          return Center(
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
          );
        },
      );
    }
  }

  Widget showMoviesContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'List of Movies',
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<List<Movie>>(
            future: fetchMovies(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Hata: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("Film bulunamadı."));
              } else {
                final movies = snapshot.data!;

                return GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: movies.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.65,
                  ),
                  itemBuilder: (context, index) {
                    final movie = movies[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MovieDetails(currentMovie: movie),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                // `movie.poster` yerine `movie.posterUrl` kullandığınızdan emin olun
                                child: buildMoviePoster(movie.poster),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                movie.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Welcome to ${currentUser.userName}!',
          style: AppTextStyle.TOP_HEADER_,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AutoImageSlider(),
            SizedBox(height: 10),
            showMoviesContent(context),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              height: 120.0,
              width: double.infinity,
              color: Colors.lightBlueAccent.shade100,
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: FlutterLogo(
                    size: 40,
                    style: FlutterLogoStyle.markOnly,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: ClampingScrollPhysics(),
                children: [
                  ListTile(
                    leading: Icon(Icons.place),
                    title: Text('Konum'),
                    trailing: Icon(Icons.arrow_right),
                  ),
                  ExpansionTile(
                    leading: Icon(Icons.adjust),
                    title: Text('Hakkımızda'),
                    trailing: Icon(Icons.arrow_drop_down),
                    children: [
                      ListTile(
                        title: Text('Biz Kimiz?'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: Text('Sertifikalarımız'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        title: Text('Misyonumuz'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
