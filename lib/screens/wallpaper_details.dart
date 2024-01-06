import 'package:flutter/material.dart';

class WallpaperDetailsPage extends StatelessWidget {
  String wallUrl;
  WallpaperDetailsPage({super.key, required this.wallUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
          child: Image.network(wallUrl, fit: BoxFit.fill ,)),
    );
  }
}
