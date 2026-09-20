import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البحث')),
      body: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: Text('Search Screen')),
        ),
      ),
    );
  }
}
