class ApiConnection {
  static const hostConnection = 'http://127.0.0.1:8000/api';

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas = '$hostConnection/cinemas';

  static const movies = '$hostConnection/movies';
  static const nowPlaying = '$hostConnection/movies/now-playing';
  static String movieById(int id) => '$hostConnection/movies/$id';
  static const futureMovies = '$hostConnection/future-movies';

  static String showTime(int cityId, int cinemaId, int movieId) =>
      '$hostConnection/cities/$cityId/cinemas/$cinemaId/movies/$movieId/showtimes';
  static String seats(int showTimeId) =>
      '$hostConnection/showtimes/$showTimeId/seats';
}
