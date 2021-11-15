// ignore_for_file: avoid_print

import 'package:http/http.dart' as http;

class Settings {
  String mainUrl =
    "https://samcloud.spacial.com/api/listen?sid=68536&rid=155608&f=mp3,any&br=96000,any&m=m3u";

  // ignore: prefer_typing_uninitialized_variables
  var newRadioLink;

  getUrl() async {
    final _myUri = Uri.parse(mainUrl);
    var _response =
        await http.get(_myUri, headers: {'Accept': 'application/json'});
    String text = (((((((_response.body).replaceAll('#EXTM3U', ''))
                            .replaceAll('#EXTINF:-1', ''))
                        .replaceAll('   ', ','))
                    .replaceAll(',  http:', 'http:'))
                .replaceAll('_SChttp:', '_SC,http:')
                .splitMapJoin((RegExp(r'\r\n|\r\n')), onMatch: (m) => ','))
            .replaceAll(',,', ','))
        .replaceFirst(',', '');

    text = (text.padRight(text.length + 1, '#')).replaceAll(',#', '');
    text = (text.replaceAll('http:', "https:")).replaceAll('.com:80/', '.com/');
    List nValue = (text.split(',')).toSet().toList();
    // ignore: prefer_typing_uninitialized_variables
    var radioUrl;

    for (var i = 0; i < 1; i++) {
      radioUrl = nValue[i];
    }

    newRadioLink = radioUrl;
    return radioUrl;
  }

}