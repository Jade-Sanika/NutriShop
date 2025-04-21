import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              'https://lh5.googleusercontent.com/proxy/D7-MI9k7yYChIcDaCy2FctjISR4VbbwSz9NXfabbwoppBuYv3aq8v2CBHtVcrsZMnD8LC2bSy5kaBWpG0kOGd_VLEgwZLIg7ib1OUw',
              width: 250, // Increased width of logo
              height: 250, // Increased height of logo
            ),
            SizedBox(height: 20),
            Text(
              'Eat Fresh, Live Healthy!',
              style: TextStyle(
                fontSize: 24, // Adjusted font size for a catchy line
                fontWeight: FontWeight.bold,
                color: Colors.white, // Text color to stand out on background
                fontStyle: FontStyle.italic, // Added italics for emphasis
              ),
            ),
          ],
        ),
      ),
    );
  }
}
