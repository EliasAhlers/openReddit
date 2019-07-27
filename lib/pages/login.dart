import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:redditclient/stores/redditStore.dart';

class Login extends StatefulWidget {
  Login({Key key}) : super(key: key);

  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String url = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: url != '' ? InAppWebView(
              initialUrl: this.url,
              onLoadStart: loadPageStart,
            ) : Container()
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    this.loginToReddit();
    super.initState();
  }

  void loadPageStart(InAppWebViewController controller, String url) {    
    if(url.toString().contains('code=')) {
      String code = url.toString().replaceAll('https://thatseliyt.de/?state=foobar&code=', '');
      this.confirmRedditLogin(code);
    }
  }

  void loginToReddit() {
    RedditStore.reddit = Reddit.createInstalledFlowInstance(
      clientId: 'yG99FCjMF8tXaA',
      userAgent: 'foobar',
    );

    final String authUrl = RedditStore.reddit.auth.url(['*'], 'foobar').toString().replaceAll('redirect_uri=null', 'redirect_uri=https%3A%2F%2Fthatseliyt.de%2F');

    setState(() {
      this.url = authUrl.toString();
    });
  }

  void confirmRedditLogin(String code) async {
    await RedditStore.reddit.auth.authorize(code);
    // Retrieve information for the currently authenticated user
    Redditor currentUser = await RedditStore.reddit.user.me();
    // Outputs: My name is DRAWApiOfficial
    print("My name is ${currentUser.displayName}");
  }

}

