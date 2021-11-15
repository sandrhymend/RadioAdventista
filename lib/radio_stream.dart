// ignore_for_file: avoid_print, must_be_immutable

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:radioapp/webview.dart';

IconData icon = Icons.pause_circle_outline;
// You might want to provide this using dependency injection rather than a
// global variable.

class RadioStream extends StatefulWidget {
  final AudioHandler _audioHandler;

  // ignore: use_key_in_widget_constructors
  const RadioStream(this._audioHandler);

  @override
  _RadioStreamState createState() => _RadioStreamState();
}

class _RadioStreamState extends State<RadioStream> {
  int _selectedIndex = 1;
  final AudioPlayer _player = AudioPlayer();

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    super.initState();

  }

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
    icon: Icon(iconData),
    iconSize: 64.0,
    onPressed: onPressed,
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_selectedIndex].currentState!.maybePop();

        // ignore: avoid_print
        print(
            'isFirstRouteInCurrentTab: ' + isFirstRouteInCurrentTab.toString());
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[700],
        bottomNavigationBar: StreamBuilder<bool>(
            stream: widget._audioHandler.playbackState
                  .map((state) => state.playing)
                  .distinct(),
              builder: (context, snapshot) {
              final playing = snapshot.data ?? false;
              return BottomNavigationBar(
                currentIndex: _selectedIndex,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      playing
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                      color: Colors.redAccent,
                      size: 62,
                    ),
                    label: 'RADIO',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(
                      Icons.facebook_outlined,
                      size: 62,
                    ),
                    label: 'VIDEO',
                    activeIcon: Icon(
                      Icons.facebook_outlined,
                      color: Colors.blue,
                      size: 62,
                    ),
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(
                      Icons.info,
                      size: 62,
                    ),
                    label: 'ABOUT',
                    activeIcon: Icon(
                      Icons.info,
                      color: Colors.blue,
                      size: 62,
                    ),
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    if (index == 0) {
                     _selectedIndex = 1;
                      if (playing) {
                         _player.pause();
                         widget._audioHandler.pause();
                        icon = Icons.play_circle_outline;
                        _button(Icons.pause, widget._audioHandler.pause);
                      } else {
                        _player.play();
                        widget._audioHandler.play();
                        icon = Icons.pause_circle_outline;
                        _button(Icons.play_arrow, widget._audioHandler.play);
                      }
                    } else {
                      if (index == 2) {
                        _showDialog(context);
                      } else {
                         _selectedIndex = index;
                      }
                   }
                  });
                },
              );
            }),
        body: Stack(
          children: [
            _buildOffstageNavigator(0),
            _buildOffstageNavigator(1),
            _buildOffstageNavigator(2),
          ],
        ),
      ),
    );
  }
Map<String, WidgetBuilder> _routeBuilders(BuildContext context, int index) {
    return {
      '/': (context) {
        return [
          WebViewPage(_player),
          WebViewPage(_player),
          WebViewPage(_player),
        ].elementAt(index);
      }
    };
  }

  Widget _buildOffstageNavigator(int index) {
    var routeBuilders = _routeBuilders(context, index);

    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          return MaterialPageRoute(
            builder: (context) => routeBuilders[routeSettings.name]!(context),
          );
        },
      ),
    );
  }

// Show Dialog function
void _showDialog(context) {
  // flutter defined function
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return alert dialog object
      return AlertDialog(
        title: const Center(
            child:
                Text('About', style: TextStyle(fontWeight: FontWeight.w800))),
        //backgroundColor: Colors.orange[50],
        content: SizedBox(
          height: 360,
          child: Card(
            //color: Colors.orange[50],
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Fundador',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                      'Southern California Conference Hispanic Region'),
                  leading: Icon(
                    Icons.map,
                    color: Colors.blue[500],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Fundada en',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('2015'),
                  leading: Icon(
                    Icons.home,
                    color: Colors.blue[500],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text('Pagina web'),
                  subtitle: const Text('radioadventistala.org'),
                  leading: Icon(
                    Icons.web,
                    color: Colors.blue[500],
                  ),
                ),
                const Divider(),
                ListTile(
                  title: const Text(
                    'Contacto',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text('(323) 539-8377'),
                  leading: Icon(
                    Icons.contact_phone,
                    color: Colors.blue[500],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 14.0,
                backgroundColor: Colors.white,
                child: Icon(Icons.close, color: Colors.red),
              ),
            ),
          ),
        ],
      );
    },
  );
}

}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;

  MediaState(this.mediaItem, this.position);
}