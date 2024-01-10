import 'package:flutter/material.dart';
import 'package:gitars_app/Widgets/podborki.dart';
import 'package:gitars_app/Widgets/tematika.dart';
import 'package:gitars_app/popular_songs_lists.dart';
import 'package:gitars_app/songs.dart';

import 'Widgets/popular_widget.dart';
import 'Widgets/top10pesen.dart';
import 'acords.dart';
import 'drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List popular = [
    [
      'lib/images/aria.png',
      'Ария',
      'Хеви-метал-группа',
      'https://3akkorda.net/russkie/ariya/'
    ],
    [
      'lib/images/bi22.png',
      'Би-2',
      'Белорусская и российская рок-группа',
      'https://3akkorda.net/russkie/bi2/'
    ],
    [
      'lib/images/max.png',
      'Макс Корж',
      'Автор песен и композитор',
      'https://3akkorda.net/russkie/maks-korzh/'
    ],
    [
      'lib/images/coi2.png',
      'Виктор Цой',
      ' Легенда Русского рока',
      'https://3akkorda.net/russkie/viktor-coj/'
    ],
    [
      'lib/images/king.png',
      'Король и Шут',
      'Хоррор-панк-группа',
      'https://3akkorda.net/russkie/korol-i-shut/'
    ],
    [
      'lib/images/shvec.png',
      'Алена Швец',
      'Автор-исполнитель,гитарист',
      'https://3akkorda.net/russkie/alena-svec/'
    ],
    [
      'lib/images/nautilius.png',
      'Nautilus Pompilius',
      'Уральско-питерская рок-группа',
      'https://3akkorda.net/russkie/nautilus-pompilius/'
    ],
  ];
  final List tematics = [
    [
      'lib/images/pfilm.png',
      'Песни из фильмов',
      'https://amdm.ru/akkordi/prikolnie_pesni/'
    ],
    [
      'lib/images/pstol2.png',
      'Народные и застольные',
      'https://amdm.ru/akkordi/popular/all/'
    ],
    [
      'lib/images/parmia2.png',
      'Военные, армейские песни',
      'https://amdm.ru/akkordi/popular/all/'
    ],
    [
      'lib/images/pcoster2.png',
      'Песни у костра',
      'https://amdm.ru/akkordi/popular/all/'
    ],
    [
      'lib/images/pdvor.png',
      'Дворовые',
      'https://amdm.ru/akkordi/popular/all/'
    ],
  ];

  final List topchic = [
    Toppesen(misic: 'Пачка сигарет', name: 'Кино'),
    Toppesen(misic: 'Батарейка', name: 'Жуки'),
    Toppesen(misic: 'Группа крови', name: 'Кино'),
    Toppesen(misic: 'Сансара', name: 'Баста'),
    Toppesen(misic: 'Вахтерам', name: 'Бумбокс'),
    Toppesen(misic: 'Кукла Колдуна', name: 'Король и Шут'),
    Toppesen(misic: 'Тёмно - оранжевый закат', name: 'Папин Олимпос'),
    Toppesen(misic: 'Просвистела', name: 'ДДТ'),
    Toppesen(misic: 'Конь', name: 'Любэ'),
    Toppesen(misic: 'Лирика', name: 'Сектор газа'),
  ];

  final List Podbor = [
    ['lib/images/gitara7.png', 'https://amdm.ru/akkordi/popular/all/'],
    ['lib/images/gitara2.png', 'https://amdm.ru/akkordi/'],
    ['lib/images/gitara3.png', 'https://amdm.ru/akkordi/popular/all/'],
    ['lib/images/gitara4.png', 'https://amdm.ru/akkordi/popular/all/'],
    ['lib/images/gitara5.png', 'https://amdm.ru/akkordi/popular/all/'],
    ['lib/images/gitara6.png', 'https://amdm.ru/akkordi/popular/all/'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      backgroundColor: Colors.grey.shade900,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),

                // Expanded(
                //   child: TextButton(
                //     onPressed: (){},
                //     child: Image.asset('lib/icons/home.png',
                //       height: 25,
                //       width: 25,
                //       color: Colors.purple,
                //     ),
                //   ),
                // ),

                // Ps
                SizedBox(height: 13),

                /*Center(
                  child: Text(
                    'Выбирай свою музыку',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
                SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 35,
                            child: Image.asset('lib/icons/lupa2.png'),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/

                SizedBox(height: 1),

                Center(
                  child: Text(
                    'Популярные исполнители',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(),
                  height: 320,
                  //margin: EdgeInsets.symmetric(horizontal: ),
                  child: PageView.builder(
                      controller:
                          PageController(viewportFraction: 0.9, initialPage: 2),
                      scrollDirection: Axis.horizontal,
                      itemCount: 7,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PopularSongs(
                                        link: popular[index][3],
                                        ispodbor: false,
                                      )),
                            );
                          },
                          child: Popular_Widget(
                            photo: popular[index][0],
                            name: popular[index][1],
                            info: popular[index][2],
                          ),
                        );
                      }),
                ),

                SizedBox(height: 25),

                Center(
                  child: Text(
                    'Лучшие подборки',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
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
                      childAspectRatio: 1,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PopularSongs(
                                      link: Podbor[index][1],
                                      ispodbor: true,
                                    )),
                          );
                        },
                        child: Podborki(
                          gitara: Podbor[index][0],
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 25),

                Center(
                  child: Text(
                    'Песни по тематике',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(),
                  height: 315,
                  //margin: EdgeInsets.symmetric(horizontal: ),
                  child: PageView.builder(
                      controller:
                          PageController(viewportFraction: 0.9, initialPage: 2),
                      scrollDirection: Axis.horizontal,
                      itemCount: tematics.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PopularSongs(
                                        link: tematics[index][2],
                                        ispodbor: true,
                                      )),
                            );
                          },
                          child: Popular_Widget(
                            photo: tematics[index][0],
                            name: tematics[index][1],
                            info: '',
                          ),
                        );
                      }),
                ),

                // SizedBox(height: 10),

                Center(
                  child: Text(
                    'Топ 10 лучших песен',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                    ),
                  ),
                ),

                SizedBox(height: 10),
                Column(
                  children: List.generate(topchic.length, (index) {
                    return topchic[index];
                  }),
                ),
                SizedBox(height: 90),
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
