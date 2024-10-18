import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audioScreen.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const ProgramDetailsScreen({super.key, required this.programId});

  @override
  ProgramDetailsScreenState createState() => ProgramDetailsScreenState();
}

class ProgramDetailsScreenState extends State<ProgramDetailsScreen> {
  Map program = {};

  @override
  void initState() {
    super.initState();
    fetchProgramDetails();
  }

  Future<void> fetchProgramDetails() async {
    try {
      final response = await http.get(Uri.parse(
          'https://inner-bhakti-flutter-server.vercel.app/api/programs/${widget.programId}'));
      if (response.statusCode == 200) {
        setState(() {
          program = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load program details');
      }
    } catch (e) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching program details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: program.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // Image with gradient overlay and text
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        child: FadeInImage.assetNetwork(
                          placeholder:
                              'assets/placeholder_image.png', // Fallback image
                          image: program['image'] ?? '',
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/placeholder_image.png',
                              fit: BoxFit.cover,
                            ); // Local fallback in case of URL error
                          },
                        ),
                      ),
                      Container(
                        height: 250,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.5),
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(program['name'] ?? '',
                                style: GoogleFonts.playfairDisplay(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: Container(
                      color: const Color.fromARGB(
                          255, 42, 48, 58), // Background color
                      padding: const EdgeInsets.all(20), // Optional padding
                      child: Text(
                        program['desc'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: "Courier",
                        ),
                      ),
                    ),
                  ),
                  // List of tracks
                  Expanded(
                    child: ListView.builder(
                      itemCount: program['tracks']?.length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: Duration(milliseconds: 600),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        AudioPlayerScreen(
                                            track: program['tracks'][index]),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  var slideAnimation = Tween<Offset>(
                                    begin: Offset(0, 1), // slide up
                                    end: Offset.zero,
                                  ).animate(animation);
                                  return SlideTransition(
                                    position: slideAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    program['tracks'][index]['name'] ?? '',
                                    style: GoogleFonts.aBeeZee(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    program['tracks'][index]['desc'] ?? '',
                                    style: GoogleFonts.playfair(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black, // Background color for the bottom bar
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
