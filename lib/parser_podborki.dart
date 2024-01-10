import 'package:gitars_app/parser.dart';
import 'package:gitars_app/save.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

//https://amdm.ru/akkordi/ddt/149136/prosvistela/
//https://amdm.ru/akkordi/popular/all/

class Parserpodbor extends Parser{

//  late List<SongItem> listpodbor2 = [];
 // late Songsave podborsave;

  // Parserpodbor() {
  //   podborsave = Songsave();
  // }

  @override
  Future<List<String>?> getSong(String url) async {
    var client = http.Client();
    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var a = parse(response.body);
      var b = a.getElementsByClassName('podbor__text').first.innerHtml;
      String song  = removeAllHtmlTags(b);
      listsong = song.split('\n');
      songsave.Setsong(listsong);
      print('aswer: $song');
      return listsong;
    }
  }
@override
  Future<List<SongItem>?> getCustomSongs(String link) async {
  listsong2.clear();
    var client = http.Client();
    var response = await client.get(Uri.parse(link));
    if (response.statusCode == 200) {
      var a = parse(response.body);
      var b = a.getElementsByClassName('artist_name');
      //List<String> element =[];
      for (int i = 0; i < b.length; i++) {
        var artist = b[i].nodes[0].nodes[0].text!;
        var linkfrom = b[i].nodes[2].attributes.values.first;
        var namesongs = b[i].nodes[2].nodes[0].text!;


          SongItem item;

          item = SongItem(
            artist: artist, songname: namesongs, link: linkfrom,
          );
        listsong2.add(item);

        //print('aswer: ${listsong2[i]}');
      }
    }

    return listsong2;
  }

}

