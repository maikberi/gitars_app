

import 'package:shared_preferences/shared_preferences.dart';

class Songsave {

  Setsong (List<String> songs) async {
    var prefs= await SharedPreferences.getInstance();
    prefs.setStringList('jopa', songs);
  }
  Future<List<String>?> Getsong () async {
    var prefs= await SharedPreferences.getInstance();
    if (prefs.containsKey('jopa')) {
      return  prefs.getStringList('jopa');
    }
    return null;
  }
}