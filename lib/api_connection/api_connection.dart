class ApiConnection {
  static const hostConnection = 'http://127.0.0.1:8000/api';

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas = '$hostConnection/cinemas';

  static const movies = '$hostConnection/movies';
  static const futureMovies = '$hostConnection/future-movies';

  static const showtimes = "$hostConnection/showtimes";
  static const halls = "$hostConnection/halls";
  static String apiResponseString(int i) =>
      "$hostConnection/showtimes/$i/available-seats";
}
