import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final String item;

  DetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Screen'),
      ),
      body: Center(
        child: Text(
          'Detailed View of $item',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}
