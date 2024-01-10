import 'package:flutter/material.dart';
import 'package:gitars_app/parser.dart';
import 'package:gitars_app/parser_podborki.dart';

class SongAcords extends StatefulWidget {
  const SongAcords({Key? key, required this.song, required bool this.ispodbor1}) : super(key: key);

  final SongItem song;
  final bool ispodbor1;

  @override
  State<SongAcords> createState() => _SongAcordsState();
}

class _SongAcordsState extends State<SongAcords> {

  late Parser parser;

  TextStyle chordsStyle = TextStyle(
      color: Colors.grey,
      //letterSpacing: 0,
      wordSpacing:5
    //fontSize: 17
  );

  TextStyle songStyle = TextStyle(
      color: Colors.white,
      //letterSpacing: 0,
      wordSpacing:5
    //fontSize: 17
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parser = widget.ispodbor1 ? Parserpodbor() : Parser();  }
  
  bool containsmatch(String str){
    if (str.contains('Am')
        || str.contains('A')
        || str.contains('A7')
        || str.contains('B')
        || str.contains('B7')
        || str.contains('Bm')
        || str.contains('C')
        || str.contains('C7')
        || str.contains('Cm')
        || str.contains('D')
        || str.contains('D7')
        || str.contains('Dm')
        || str.contains('E')
        || str.contains('E7')
        || str.contains('Em')
        || str.contains('F')
        || str.contains('F7')
        || str.contains('Fm')
        || str.contains('G')
    )
      return true;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,

        title: Text(widget.song.songname),
      ),
      body:  SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),


            FutureBuilder<List<String>?>(
              future: parser.getSong(widget.song.link),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData){
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:
                      List.generate(parser.listsong.length, (index) {
                        TextStyle mytextstyle;
                        if (containsmatch(parser.listsong[index]))
                          mytextstyle = chordsStyle;
                        else
                          mytextstyle = songStyle;
                        return Text(parser.listsong[index].replaceAll('  ', '    '), style: mytextstyle,);
                      }
                      ),
                    ),
                  );
                }
                else{
                  return Container(
                      height: 650,
                      child: Center(child: CircularProgressIndicator(
                        color: Colors.purple,
                      )));
                }
              },

            ),
            SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}
