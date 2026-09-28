import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:gitars_app/app.dart';
import 'package:gitars_app/data/services/favorites_store.dart';

void main() {
  testWidgets('Home screen renders with bottom navigation', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<FavoritesStore>(
        create: (_) => FavoritesStore(),
        child: const GitarsApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Гитара'), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
