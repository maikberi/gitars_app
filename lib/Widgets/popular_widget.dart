import 'package:flutter/material.dart';

class Popular_Widget extends StatelessWidget {

  final String photo;
  final String name;
  final String info;

  Popular_Widget({
    required this.photo,
    required this.name,
    required this.info,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          SizedBox(height: 25),


          Container(
            width: 350,
            height: 230,
            child: FittedBox(child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
                child: Image.asset(photo)),
              //fit: BoxFit.fill,
            ),
          ),
          SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(name,
              style: TextStyle(
                fontSize: 17,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 1),
          info.isEmpty ? Container() : Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(info,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
