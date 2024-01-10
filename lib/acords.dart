import 'package:flutter/material.dart';
import 'package:gitars_app/Widgets/acord_widget.dart';
import 'package:gitars_app/homepage.dart';
import 'package:gitars_app/songs.dart';

class Acords extends StatefulWidget {
  const Acords({Key? key}) : super(key: key);

  @override
  State<Acords> createState() => _AcordsState();
}

class _AcordsState extends State<Acords> {
  final List acrord = [
    ['lib/acords/Am.png', 'Am'],
    ['lib/acords/C.png', 'C'],
    ['lib/acords/A.png', 'A'],
    ['lib/acords/D.png', 'D'],
    ['lib/acords/Dm.png', 'Dm'],
    ['lib/acords/Em.png', 'Em'],
    ['lib/acords/G.png', 'G'],
    ['lib/acords/E.png', 'E'],
    ['lib/acords/Bm.png', 'Bm'],
    ['lib/acords/F.png', 'F'],
  ];

  final List acrord_n = [
    ['lib/acords/A.png', 'A'],
    ['lib/acords/A7.png', 'A7'],
    ['lib/acords/Am.png', 'Am'],
    ['lib/acords/B.png', 'B'],
    ['lib/acords/B7.png', 'B7'],
    ['lib/acords/Bm.png', 'Bm'],
    ['lib/acords/C.png', 'C'],
    ['lib/acords/C7.png', 'C7'],
    ['lib/acords/Cm.png', 'Cm'],
    ['lib/acords/D.png', 'D'],
    ['lib/acords/D7.png', 'D7'],
    ['lib/acords/Dm.png', 'Dm'],
    ['lib/acords/E.png', 'E'],
    ['lib/acords/E7.png', 'E7'],
    ['lib/acords/Em.png', 'Em'],
    ['lib/acords/F.png', 'F'],
    ['lib/acords/F7.png', 'F7'],
    ['lib/acords/Fm.png', 'Fm'],
    ['lib/acords/G.png', 'G'],
    ['lib/acords/Gm.png', 'Gm'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    'Основные аккорды',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // ПОИСК АКОРДОВ

                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 15.0),
                //   child: Container(
                //     decoration: BoxDecoration(
                //       color: Colors.grey[200],
                //       borderRadius: BorderRadius.circular(13),
                //     ),
                //
                //     child: Row(
                //       children: [
                //         Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Container(
                //             height: 35,
                //             child: Image.asset('lib/icons/lupa2.png'),
                //           ),
                //         ),
                //         Expanded
                //           (child: TextField(
                //           decoration: InputDecoration(
                //               border: InputBorder.none
                //           ),
                //         ),
                //         ),
                //
                //         SizedBox(height: 20),
                //       ],
                //     ),
                //   ),
                // ),

                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.zero,
                            topRight: Radius.circular(16),
                            bottomLeft: Radius.zero,
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        height: 80,
                        width: double.infinity,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 10.0,
                              ),
                              child: Text(
                                '10',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 35,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10.0, top: 10),
                                child: Text(
                                  'базовых аккордов для новичков',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Row(
                        children: [
                          Expanded(flex: 12, child: Container()),
                          Transform.rotate(
                            angle: 25,
                            child: Image.asset(
                              'lib/icons/acord.png',
                              color: Colors.white,
                            ),
                          ),
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, index) {
                      return AcordsWidget(
                        photo2: acrord[index][0],
                        name2: acrord[index][1],
                      );
                    },
                  ),
                ),

                SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.only(right: 40.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.zero,
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    height: 80,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0, top: 10),
                            child: Text(
                              'Основные аккорды для начинающих',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return AcordsWidget(
                        photo2: acrord_n[index][0],
                        name2: acrord_n[index][1],
                      );
                    },
                  ),
                ),
                SizedBox(height: 100),
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
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => HomePage()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Image.asset(
                                'lib/icons/home.png',
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
                                'lib/icons/acord.png',
                                height: 25,
                                width: 25,
                                color: Colors.purple,
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
