import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:sinema_uygulamasi/components/cinemas.dart';
import 'package:sinema_uygulamasi/components/movies.dart';
import 'package:sinema_uygulamasi/constant/app_color_style.dart';
import 'package:sinema_uygulamasi/screens/cinema_select.dart';
import 'package:sinema_uygulamasi/components/showtimes.dart';
import 'package:sinema_uygulamasi/screens/ticket_screen.dart';
import 'package:sinema_uygulamasi/screens/showtimes_screen.dart';

class BuyScreen extends StatefulWidget {
  final Movie? currentMovie;
  final Showtime? selectedShowtime;
  final Cinema? currentCinema;
  final bool fromMovieDetails;

  const BuyScreen({
    super.key,
    required this.currentMovie,
    required this.selectedShowtime,
    required this.currentCinema,
    this.fromMovieDetails = false,
  });

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  Cinema? currentCinema;
  Showtime? selectedShowtime;

  final Color buttonColor = Colors.amber;
  final Color buttonTextColor = AppColorStyle.textPrimary;
  final String buttonText = "Continue to Seat Selection";

  @override
  void initState() {
    super.initState();
    currentCinema = widget.currentCinema;
    selectedShowtime = widget.selectedShowtime;
  }

  Widget buildMoviePoster(String posterUrl) {
    if (posterUrl.isEmpty || posterUrl == 'N/A') {
      return Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: AppColorStyle.appBarColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.broken_image_outlined,
          size: 60,
          color: AppColorStyle.secondaryAccent,
        ),
      );
    }

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
            color: AppColorStyle.appBarColor,
            child: const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: AppColorStyle.secondaryAccent,
            ),
          );
        },
      ),
    );
  }

  void _selectShowtime() async {
    if (currentCinema == null || widget.currentMovie == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a cinema first.')),
      );
      return;
    }

    final selectedShowtimeResult = await Navigator.push<Showtime>(
      context,
      MaterialPageRoute(
        builder: (context) => ShowtimesScreen(
          selectedCinema: currentCinema!,
          currentMovie: widget.currentMovie!,
        ),
      ),
    );
    if (selectedShowtimeResult != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BuyScreen(
            currentMovie: widget.currentMovie,
            currentCinema: currentCinema,
            selectedShowtime: selectedShowtimeResult,
            fromMovieDetails: widget.fromMovieDetails,
          ),
        ),
      );
    }
  }

  void _navigateBack() {
    if (widget.fromMovieDetails) {
      Navigator.pop(context, {
        'movie': widget.currentMovie,
        'cinema': currentCinema,
        'showtime': selectedShowtime,
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.currentMovie;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColorStyle.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Buy Ticket',
            style: TextStyle(color: AppColorStyle.textPrimary),
          ),
          centerTitle: true,
          backgroundColor: AppColorStyle.appBarColor,
          iconTheme: const IconThemeData(color: AppColorStyle.textPrimary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Movie Information
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (movie != null) buildMoviePoster(movie.poster),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie?.title ?? 'Movie Title',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColorStyle.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Genre: ${movie?.genre ?? '...'}',
                            style: const TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                          Text(
                            'Duration: ${movie?.runtime ?? '...'}',
                            style: const TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                          Text(
                            'Release Date: ${movie != null ? DateFormat.yMMMMd('en').format(movie.releaseDate) : '...'}',
                            style: const TextStyle(
                              color: AppColorStyle.textSecondary,
                            ),
                          ),
                          if (selectedShowtime != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Showtime: ${DateFormat('dd MMM - HH:mm').format(selectedShowtime!.startTime)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColorStyle.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Cinema Selection
                _buildSelectionContainer(
                  title: 'Cinema Selection',
                  icon: FontAwesomeIcons.repeat,
                  onPressed: () async {
                    final selectedCinemaResult = await Navigator.push<Cinema>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CinemaSelect(currentMovie2: movie),
                      ),
                    );
                    if (selectedCinemaResult != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyScreen(
                            currentMovie: widget.currentMovie,
                            currentCinema: selectedCinemaResult,
                            selectedShowtime: selectedShowtime,
                            fromMovieDetails: widget.fromMovieDetails,
                          ),
                        ),
                      );
                    }
                  },
                  child: currentCinema != null
                      ? _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          title: currentCinema!.cinemaName,
                          subtitle: currentCinema!.cinemaAddress,
                        )
                      : _buildPlaceholderText('Please select a cinema.'),
                ),

                _buildSelectionContainer(
                  title: 'Hall and Showtime',
                  icon: FontAwesomeIcons.repeat,
                  onPressed: _selectShowtime,
                  child: selectedShowtime != null
                      ? _buildInfoRow(
                          icon: Icons.event_seat_outlined,
                          title: 'Hall: ${selectedShowtime!.hallname}',
                          subtitle:
                              'Date: ${DateFormat('dd MMM yyyy - HH:mm').format(selectedShowtime!.startTime)}',
                        )
                      : _buildPlaceholderText('Please select a showtime.'),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: selectedShowtime != null && currentCinema != null
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketSelectionScreen(
                          currentCinema: currentCinema!,
                          currentMovie: widget.currentMovie!,
                          selectedShowtime: selectedShowtime!,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: buttonTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildSelectionContainer({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColorStyle.appBarColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColorStyle.primaryAccent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColorStyle.textPrimary,
                ),
              ),
              IconButton(
                icon: Icon(
                  icon,
                  color: AppColorStyle.secondaryAccent,
                  size: 20,
                ),
                onPressed: onPressed,
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColorStyle.secondaryAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColorStyle.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColorStyle.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderText(String text) {
    return Text(
      text,
      style: const TextStyle(color: AppColorStyle.secondaryAccent),
    );
  }
}
