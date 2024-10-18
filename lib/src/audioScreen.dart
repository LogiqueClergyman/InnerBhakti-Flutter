import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.track});

  final Map<String, dynamic> track;

  @override
  AudioPlayerScreenState createState() => AudioPlayerScreenState();
}

class AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Color backgroundColor = Colors.white;
  Color buttonColor = Colors.black;
  Color textColor = Colors.black;
  Color seekBarColor = Colors.black;
  bool isLoadingPalette = true;

  @override
  void initState() {
    super.initState();
    _initPalette();
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() {
        duration = newDuration;
      });
    });
    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() {
        position = newPosition;
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  Future<void> _initPalette() async {
    try {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(
        NetworkImage(widget.track['image']),
      );

      setState(() {
        backgroundColor =
            paletteGenerator.lightMutedColor?.color ?? Colors.orangeAccent;
        buttonColor = paletteGenerator.darkVibrantColor?.color ?? Colors.black;
        textColor = paletteGenerator.darkMutedColor?.color ?? Colors.black;
        seekBarColor = paletteGenerator.darkMutedColor?.color ?? Colors.white;
        isLoadingPalette = false;
      });
    } catch (e) {
      showErrorToast('Failed to load image.');
      setState(() {
        isLoadingPalette = false;
        backgroundColor = Colors.grey; // Fallback background color
      });
    }
  }

  Future<void> togglePlayPause() async {
    setState(() {
      isLoading = true; // Start loading
    });

    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.track['audioUrl']));
      }

      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isPlaying = !isPlaying;
        });
      }
    } catch (e) {
      showErrorToast('Failed to load audio.');
      if (mounted) {
        Navigator.of(context)
            .pop(); // Ensure context is valid before navigating back
      }
    } finally {
      if (mounted) {
        // Check if the widget is still mounted
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    }
  }

  Future<void> forwardAudio() async {
    final newPosition = position + Duration(seconds: 10);
    if (newPosition < duration) {
      await _audioPlayer.seek(newPosition);
    }
  }

  Future<void> rewindAudio() async {
    final newPosition = position - Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _audioPlayer.seek(newPosition);
    }
  }

  bool _hasShownImageToast = false; // Flag for image toast
  bool _hasShownAudioToast = false; // Flag for audio toast
  void showErrorToast(String message, {bool isImageError = false}) {
    if (isImageError && _hasShownImageToast)
      return; // Prevent repeated image toast
    if (!isImageError && _hasShownAudioToast)
      return; // Prevent repeated audio toast
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    if (isImageError) {
      _hasShownImageToast = true; // Set flag for image error
    } else {
      _hasShownAudioToast = true; // Set flag for audio error
    }

    // Reset the flag after a certain time to allow future toasts
    Future.delayed(Duration(seconds: 5), () {
      if (isImageError) {
        _hasShownImageToast = false;
      } else {
        _hasShownAudioToast = false;
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: isLoadingPalette
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),

                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0), // Adjust padding as needed
                        child: Text(
                          widget.track['name'],
                          style: GoogleFonts.yesevaOne(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1, // Limit to one line
                          overflow: TextOverflow
                              .ellipsis, // Show ellipsis if text overflows
                          softWrap: false, // Prevent wrapping
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.track['desc'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.satisfy(
                          fontSize: 20,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.track['image']),
                        fit: BoxFit.cover,
                        onError: (_, __) {
                          showErrorToast('Failed to load image.');
                        },
                      ),
                    ),
                  ),

                  // Share and Like buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.track['name'],
                            style: GoogleFonts.alice(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Singer's name",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 14,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.share, color: buttonColor),
                            onPressed: () {
                              // Share functionality goes here
                            },
                          ),
                          IconButton(
                            icon:
                                Icon(Icons.favorite_border, color: buttonColor),
                            onPressed: () {
                              // Like functionality goes here
                            },
                          ),
                        ],
                      ),
                    ],
                  ),

                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5.0),
                            trackHeight: 2.0,
                            activeTrackColor: seekBarColor,
                            inactiveTrackColor: Colors.white38,
                          ),
                          child: Slider(
                            activeColor: seekBarColor,
                            min: 0,
                            max: duration.inSeconds.toDouble(),
                            value: position.inSeconds.toDouble(),
                            onChanged: (value) {
                              final newPosition =
                                  Duration(seconds: value.toInt());
                              _audioPlayer.seek(newPosition);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatDuration(position),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              formatDuration(duration),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 48,
                        icon: Icon(Icons.replay_10, color: buttonColor),
                        onPressed: rewindAudio,
                      ),
                      IconButton(
                        // Play / Pause button or loading indicator
                        iconSize: 98,
                        icon: isLoading
                            ? CircularProgressIndicator(
                                color: buttonColor,
                              )
                            : Icon(isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled),
                        color: buttonColor,
                        onPressed: isLoading ? null : togglePlayPause,
                      ),
                      SizedBox(height: 40),
                      IconButton(
                        iconSize: 48,
                        icon: Icon(Icons.forward_10, color: buttonColor),
                        onPressed: forwardAudio,
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
