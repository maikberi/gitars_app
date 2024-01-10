import 'package:flutter/material.dart';

class Tematika extends StatelessWidget {

  final String photo2;
  final String name2;

  Tematika({
    required this.photo2,
    required this.name2,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 350,
            height: 230,
            child: FittedBox(child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.asset(photo2)),
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(name2,
              style: TextStyle(

                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 1),

        ],
      ),
    );
  }


}