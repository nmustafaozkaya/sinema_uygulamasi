class ApiConnection {
  static const hostConnection = 'http://192.168.8.151:8000/api';

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas(int cityId) => '$hostConnection/cities/$cityId/cinemas';

  static const movies = '$hostConnection/movies';
  static const nowPlaying = '$hostConnection/movies';
  static String movieById(int id) => '$hostConnection/movies/$id';
  static const allCinemasapi = '$hostConnection/cities/all-cinemas';
  static const futureMovies = '$hostConnection/future-movies';
}
