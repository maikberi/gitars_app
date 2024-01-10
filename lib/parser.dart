
import 'package:gitars_app/save.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

//https://amdm.ru/akkordi/ddt/149136/prosvistela/
//https://amdm.ru/akkordi/popular/all/

class Parser {

  late List<String> listsong;
  late List<SongItem> listsong2 = [];
  late Songsave songsave;

  Parser() {
     songsave = Songsave();
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }

  Future<List<String>?> getSong(String url) async {
    var client = http.Client();
    var response = await client.get(Uri.parse(url));
    if (response.statusCode == 200) {
     var a = parse(response.body);
     var b = a.getElementsByClassName('verse').first.innerHtml;
     String song  = removeAllHtmlTags(b);
     listsong = song.split('\n');
     songsave.Setsong(listsong);
     print('aswer: $song');
    return listsong;
   }
  }

  Future<List<SongItem>?> getCustomSongs(String link) async {
    listsong2.clear();
    var client = http.Client();
    var response = await client.get(Uri.parse(link));
    if (response.statusCode == 200) {
      var a = parse(response.body);
      var b = a.getElementsByClassName('post-inner post-hover');
      //List<String> element =[];
      for (int i = 0; i < b.length; i++) {
        var namesongartist = b[i].nodes[0].nodes[1].nodes[0].text!;
        var linkfrom = b[i].nodes[0].nodes[1].attributes.values.first;

        if (namesongartist.contains('–')){
          SongItem item;
          var name = namesongartist.split(' – ')[1];
          var artist = namesongartist.split(' – ')[0];
          item = SongItem(
            artist: artist, songname: name, link: linkfrom,
          );
          listsong2.add(item);
        }
        //print('aswer: ${listsong2[i]}');
      }
    }

    return listsong2;
  }


  Future<List<SongItem>?> getListSong(String xuy, String? sirchword) async {
    listsong2.clear();
    var client = http.Client();
    if (sirchword!= null )
      {
        var response = await client.get(Uri.parse('https://3akkorda.net/page/$xuy/?s=$sirchword'));
        if (response.statusCode == 200) {
          var a = parse(response.body);
          var b = a.getElementsByClassName('post-inner post-hover');
          //List<String> element =[];
          for (int i = 0; i < b.length; i++) {
            var namesongartist = b[i].nodes[1].nodes[1].nodes[0].text!;
            var linkfrom = b[i].nodes[1].nodes[1].attributes.values.first;
            if (namesongartist.contains('–')){
              SongItem item;
              var name = namesongartist.split(' – ')[1];
              var artist = namesongartist.split(' – ')[0];
              item = SongItem(
                artist: artist, songname: name, link: linkfrom,
              );
              listsong2.add(item);
            }
            //print('aswer: ${listsong2[i]}');
          }
        }

        return listsong2;
      }
    var response = await client.get(Uri.parse('https://3akkorda.net/page/$xuy/'));
    if (response.statusCode == 200) {
      var a = parse(response.body);
      var b = a.getElementsByClassName('post-inner post-hover');
      //List<String> element =[];
      for (int i = 0; i < b.length; i++) {
        var namesongartist = b[i].nodes[1].nodes[1].nodes[0].text!;
        var linkfrom = b[i].nodes[1].nodes[1].attributes.values.first;

        if (namesongartist.contains('–')){
          SongItem item;
          var name = namesongartist.split(' – ')[1];
          var artist = namesongartist.split(' – ')[0];
          item = SongItem(
            artist: artist, songname: name, link: linkfrom,
          );
          listsong2.add(item);
        }
          //print('aswer: ${listsong2[i]}');
        }
      }

    return listsong2;
  }
}

class SongItem {

  SongItem({required this.artist, required this.songname, required this.link});

  final String artist;
  final String songname;
  final String link;

}