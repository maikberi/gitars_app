import 'package:flutter/material.dart';

class Podborki extends StatelessWidget {

  late String gitara;


  Podborki({
    required this.gitara,

  });


  @override
  Widget build(BuildContext context) {
    return Container(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
          child: Image.asset(gitara,
          fit: BoxFit.cover,
          ),
      ),
    );
  }


}
