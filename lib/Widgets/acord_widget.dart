import 'package:flutter/material.dart';

class AcordsWidget extends StatelessWidget {

  final String photo2;
  final String name2;

  AcordsWidget({
    required this.photo2,
    required this.name2,
  });


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Center(
            child: Text(name2,
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 10),

        Container(
         // height: 140 ,
          child: Image.asset(photo2,
            fit: BoxFit.cover,
          ),
        ),

      ],
    );
  }
}


