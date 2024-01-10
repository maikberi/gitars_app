import 'package:flutter/material.dart';
import 'package:gitars_app/acords.dart';
import 'package:gitars_app/parser.dart';
import 'package:gitars_app/parser_podborki.dart';
import 'package:gitars_app/song_acords.dart';
import 'package:gitars_app/songs.dart';

import 'homepage.dart';

class PopularSongs extends StatefulWidget {
  const PopularSongs({Key? key, String? this.link, required bool this.ispodbor})
      : super(key: key);

  final String? link;
  final bool ispodbor;

  @override
  State<PopularSongs> createState() => _PopularSongsState();
}

class _PopularSongsState extends State<PopularSongs> {
  late Parser parser;
  TextEditingController textcontroler = TextEditingController();
  int pageindex = 1;
  String? sirchword;

  TextStyle artistStyle = TextStyle(
      color: Colors.white,
      //letterSpacing: 0,
      fontSize: 17);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parser = widget.ispodbor ? Parserpodbor() : Parser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<List<SongItem>?>(
                  future: parser.getCustomSongs(widget.link!),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.connectionState != ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(parser.listsong2.length, (index) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 7),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SongAcords(
                                                    song:
                                                        parser.listsong2[index],
                                                    ispodbor1: false,
                                                  )),
                                        );
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 5.0),
                                            child: Text(
                                              parser.listsong2[index].songname,
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 1),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 5.0),
                                            child: Text(
                                              parser.listsong2[index].artist,
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(),
                                  ),
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
                            // TextStyle mytextstyle;
                            // if (parser.listsong2[index].contains('Am'))
                            //   mytextstyle = chordsStyle;
                            // else
                            //   mytextstyle = songStyle;
                            // return Text(parser.listsong2[index].replaceAll('  ', '    '), style: mytextstyle,);
                          }),
                        ),
                      );
                    } else {
                      return Container(
                          height: 650,
                          child: Center(
                              child: CircularProgressIndicator(
                            color: Colors.purple,
                          )));
                    }
                  },
                ),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
          Hero(
            tag: 'botbar',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => Songs()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Image.asset(
                                'lib/icons/music.png',
                                height: 25,
                                width: 25,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {},
                              child: Image.asset(
                                'lib/icons/home.png',
                                height: 25,
                                width: 25,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (_) => Acords()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Image.asset(
                                'lib/icons/acord.png',
                                height: 25,
                                width: 25,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  width: double.infinity,
                  height: 100,
                  //color: Colors.amber,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black, Colors.transparent])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
