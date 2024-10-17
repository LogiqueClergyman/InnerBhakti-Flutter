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
    final response = await http.get(
        Uri.parse('http://192.168.31.66:8080/api/programs/${widget.programId}'));
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
      appBar: AppBar(
        title: Text('Program Details'),
      ),
      body: program.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Hero(
                  tag: 'program-image-${widget.programId}',
                  child: Image.network(program['image']),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: program['tracks'].length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(program['tracks'][index]['name']),
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 600),
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      AudioPlayerScreen(
                                          trackUrl: program['tracks'][index]
                                              ['audioUrl']),
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
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
