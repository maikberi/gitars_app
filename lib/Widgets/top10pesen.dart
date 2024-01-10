import 'package:flutter/material.dart';

class Toppesen extends StatelessWidget {

  final String name;
  final String misic;

  Toppesen({
    required this.name,
    required this.misic,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 7),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(misic,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 1),
              Padding(
                padding: const EdgeInsets.only(left: 5.0),
                child: Text(name,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          Expanded(child: Container(),),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Icon(
                Icons.star_border,
                color: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}