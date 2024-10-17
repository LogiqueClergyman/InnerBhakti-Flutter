import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'audioScreen.dart';

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
    final response = await http.get(Uri.parse(
        'http://192.168.31.66:8080/api/programs/${widget.programId}'));
    if (response.statusCode == 200) {
      setState(() {
        program = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load program details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Set the background color to black
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
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(program['image']),
                            fit: BoxFit.cover,
                          ),
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
                            Text(
                              program['name'],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    child: Container(
                      color: const Color.fromARGB(255, 42, 48, 58), // Background color
                      padding: const EdgeInsets.all(20), // Optional padding
                      child: Text(
                        program['desc'],
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: "Courier"),
                      ),
                    ),
                  ),

                  // List of tracks
                  Expanded(
                    child: ListView.builder(
                      itemCount: program['tracks'].length,
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
                                    program['tracks'][index]['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    program['tracks'][index]['desc'],
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 14,
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
            // You can add more buttons here if needed
          ],
        ),
      ),
    );
  }
}
