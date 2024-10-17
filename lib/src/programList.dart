import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'programDetails.dart';

class ProgramListScreen extends StatefulWidget {
  const ProgramListScreen({super.key});
  @override
  ProgramListScreenState createState() => ProgramListScreenState();
}

class ProgramListScreenState extends State<ProgramListScreen> {
  List programs = [];

  @override
  void initState() {
    super.initState();
    fetchPrograms();
  }

  Future<void> fetchPrograms() async {
    final response =
        await http.get(Uri.parse('http://192.168.31.66:8080/api/programs'));
    if (response.statusCode == 200) {
      setState(() {
        programs = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load programs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Programs'),
      ),
      body: programs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            ProgramDetailsScreen(
                                programId: programs[index]['_id']),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: ListTile(
                    leading: SizedBox(
                      width: 100, // Set a fixed width for the leading image
                      child: Hero(
                        tag: 'program-image-${programs[index]['id']}',
                        child: Image.network(programs[index]['image'],
                            fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(programs[index]['name'] ?? 'Unnamed Program'),
                  ),
                );
              },
            ),
    );
  }
}
