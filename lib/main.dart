import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/services/favorites_store.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(systemNavigationBarColor: Colors.grey.shade900),
  );

  final favoritesStore = FavoritesStore()..load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoritesStore>.value(value: favoritesStore),
      ],
      child: const GitarsApp(),
    ),
  );
}
