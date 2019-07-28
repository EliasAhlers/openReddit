import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappbrowser/flutter_inappbrowser.dart';
import 'package:random_string/random_string.dart';
import 'package:redditclient/screens/homeScreen.dart';
import 'package:redditclient/stores/redditStore.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool error = false;
  String url = '';
  String errorText = '';
  String errorReason = '';
  String state = randomAlphaNumeric(16);

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
            ) : Container(
              child: Center(
                child: this.error ? 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(this.errorText + ' '),
                      Text(this.errorReason),
                      ButtonTheme(
                        child: RaisedButton(
                          child: Text('Retry'),
                          onPressed: () {
                            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return LoginScreen(); }));
                          },
                        ),
                      )
                    ],
                  ) : Container(),
              )
              ,
            )
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
      String code = url.toString().replaceAll('https://thatseliyt.de/?state=' + this.state + '&code=', '');
      this.confirmRedditLogin(code);
    } else if(url.toString().contains('error')) {
      setState(() {
        this.url = '';
        this.error = true;
        this.errorText = 'Error while authenticating, please try again.';
        this.errorReason = url.replaceAll('https://thatseliyt.de/?state=' + this.state + '&error=', '');
      });
    }
  }

  void loginToReddit() {
    RedditStore.reddit = Reddit.createInstalledFlowInstance(
      clientId: 'yG99FCjMF8tXaA',
      userAgent: randomAlphaNumeric(10),
      redirectUri: Uri.parse('https://thatseliyt.de/')
    );

    final String authUrl = RedditStore.reddit.auth.url(['*'], this.state, compactLogin: true).toString();

    setState(() {
      this.url = authUrl.toString();
    });
  }

  void confirmRedditLogin(String code) async {
    try {
      await RedditStore.reddit.auth.authorize(code);
    } catch (e) {
      setState(() {
        this.url = '';
        this.error = true;
        this.errorText = 'Error while authenticating! Please try again'; 
      });
      return;
    }
    Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return HomeScreen(); }));
  }

}

