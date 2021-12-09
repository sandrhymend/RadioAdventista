// ignore_for_file: avoid_print, use_key_in_widget_constructors, must_be_immutable, empty_catches

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:webview_flutter/webview_flutter.dart';


const String kNavigationPage = '''
<!DOCTYPE html><html>
<head><title>Navigation Delegate</title></head>
<body>
<p>
The navigation delegate is set to block navigation to the youtube website.
</p>
<ul>
<ul><a href="https://www.youtube.com/channel/UC1T_XyYVMZvpgwWKwZ-pBUA/videos/">https://www.youtube.com/channel/UC1T_XyYVMZvpgwWKwZ-pBUA/videos/</a></ul>
<ul><a href="https://www.google.com/">https://www.google.com/</a></ul>
</ul>
</body>
</html>
''';

class WebViewPage extends StatefulWidget {
  AudioPlayer player;

  // ignore: use_key_in_widget_constructors
  WebViewPage(this.player);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _myController;
  final Completer<WebViewController> _controller =
     Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  final Text pageTitle = const Text('Radio Adventista Los Angeles');
  final String selectedUrl =
      'https://m.facebook.com/pg/radioadventistalosangeles/posts/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: pageTitle,
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        actions: <Widget>[
          NavigationControls(_controller.future),
        ],
      ),
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: selectedUrl,
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _myController = webViewController;
            _controller.complete(webViewController);
          },
          onProgress: (int progress) {
            try {
              _myController.runJavascript("document.getElementById('mobile_login_bar').style.display='none';");
               print("WebView is loading (progress : $progress%)");
            } catch (e) {
              print('Este es el error: ' + e.toString());
            }

          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith(
                'https://www.youtube.com/channel/UC1T_XyYVMZvpgwWKwZ-pBUA/videos/')) {
              print('bloccking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            // evaluateJavascript is a method to customize the UI, here i find searchfield class name and writing a javascript query string.
            //_myController.runJavascript("document.getElementsByClassName('_1n7d')[0].style.display='none';");
            try {
              _myController.runJavascript("document.getElementById('msite-pages-header-contents').style.display='none';document.getElementById('header').style.display='none';");
            } catch (e) {
              print(e.toString());
            }

          },
          gestureNavigationEnabled: true,
        );
      }),
      //floatingActionButton: favoriteButton(),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(this._webViewControllerFuture);
  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data!;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoBack()) {
                        await controller.goBack();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(content: Text("No back history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        // ignore: deprecated_member_use
                        Scaffold.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("No forward history item")),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      print('controller reload');
                      controller.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}
