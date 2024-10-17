import 'package:flutter/material.dart';
import './src/programList.dart'; // Import your ProgramListScreen here

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Program App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProgramListScreen(), // Set the ProgramListScreen as the home
    );
  }
}
