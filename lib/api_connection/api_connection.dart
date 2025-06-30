class ApiConnection {
  static const hostConnection = 'http://127.0.0.1:8000/api';

  static const signUp = '$hostConnection/register';
  static const login = '$hostConnection/login';
  static const cities = '$hostConnection/cities';
  static String cinemas(int cityId) => '$hostConnection/cities/$cityId/cinemas';

  static const movies = '$hostConnection/movies';
  static const nowPlaying = '$hostConnection/movies/now-playing';
  static String movieById(int id) => '$hostConnection/movies/$id';
  static const allCinemasapi = '$hostConnection/cities/all-cinemas';
  static const futureMovies = '$hostConnection/future-movies';

  static String showTime(int cinemaId, int movieId) =>
      '$hostConnection/cinemas/$cinemaId/movies/$movieId/showtimes';

  static String seats(int showTimeId) =>
      '$hostConnection/showtimes/$showTimeId/seats';
}
