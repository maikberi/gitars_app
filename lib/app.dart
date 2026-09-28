import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/songs_repository.dart';
import 'features/chords/chords_screen.dart';
import 'features/home/home_screen.dart';
import 'features/metronome/metronome_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/songs/songs_screen.dart';
import 'features/tuner/tuner_screen.dart';

class GitarsApp extends StatelessWidget {
  const GitarsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Гитара',
      theme: AppTheme.dark,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _repository = SongsRepository();
  int _index = 0;

  late final List<Widget> _pages = [
    HomeScreen(repository: _repository),
    SongsScreen(repository: _repository),
    const TunerScreen(),
    const MetronomeScreen(),
    const ChordsScreen(),
    const ProfileScreen(),
  ];

  static const _items = [
    BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Главная'),
    BottomNavigationBarItem(icon: Icon(Icons.library_music_rounded), label: 'Песни'),
    BottomNavigationBarItem(icon: Icon(Icons.speed_rounded), label: 'Тюнер'),
    BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Метроном'),
    BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Аккорды'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Профиль'),
  ];

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: _items,
      ),
    );
  }
}
