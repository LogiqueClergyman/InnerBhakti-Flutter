import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:palette_generator/palette_generator.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key, required this.track});

  final Map<String, dynamic> track;

  @override
  AudioPlayerScreenState createState() => AudioPlayerScreenState();
}

class AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  Color backgroundColor = Colors.white; // Default background color
  Color buttonColor = Colors.black; // Default button color
  Color textColor = Colors.black; // Default text color
  Color seekBarColor = Colors.black; // Default seek bar color
  bool isLoadingPalette = true; // Flag to check if palette is loading

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
        isPlaying = false; // Reset state after playback complete
      });
    });
  }

  Future<void> _initPalette() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      NetworkImage(widget.track['image']),
    );

    setState(() {
      backgroundColor = paletteGenerator.lightMutedColor?.color ?? Colors.orangeAccent;
      buttonColor = paletteGenerator.darkVibrantColor?.color ?? Colors.black;
      textColor = paletteGenerator.vibrantColor?.color ?? Colors.black; // Ensure text is always visible
      seekBarColor = paletteGenerator.dominantColor?.color ?? Colors.white;
      isLoadingPalette = false; // Update the loading state
    });
  }

  Future<void> togglePlayPause() async {
    try {
      if (isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.track['audioUrl']));
      }
      setState(() {
        isPlaying = !isPlaying;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
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
      backgroundColor: backgroundColor, // Dynamic background color
      body: SafeArea(
        child: isLoadingPalette // Show loading indicator until palette is ready
            ? Center(child: CircularProgressIndicator())
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top AppBar with back and close icons
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

                  // Title and description
                  Column(
                    children: [
                      Text(
                        widget.track['name'],
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.track['desc'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),

                  // Image for the track
                  Container(
                    height: 300,
                    width: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(widget.track['image']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

// Share and Like buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.track['name'],
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            "Singer's name",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: Icon(Icons.share, color: buttonColor),
                              onPressed: () {
                                // Share functionality goes here
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.favorite_border,
                                  color: buttonColor),
                              onPressed: () {
                                // Like functionality goes here
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Playback slider and controls
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5.0), // Adjust thumb size
                            trackHeight: 2.0,
                            activeTrackColor: seekBarColor,
                            inactiveTrackColor: Colors.white38,
                          ),
                          child: Slider(
                            activeColor: Colors.black,
                            inactiveColor: Colors.black26,
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

                  IconButton(
                    // Play / Pause button
                    iconSize: 98,
                    icon: Icon(isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled),
                    color: buttonColor,
                    onPressed: togglePlayPause,
                  ),
                  SizedBox(height: 40),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer
        .dispose(); // Properly dispose of the player to avoid memory leaks
    super.dispose();
  }
}
