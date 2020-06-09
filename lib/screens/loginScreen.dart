import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:openReddit/screens/homeScreen.dart';
import 'package:openReddit/screens/setupProcess/readySetupScreen.dart';
import 'package:openReddit/screens/setupProcess/welcomeSetupScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:random_string/random_string.dart';

class LoginScreen extends StatefulWidget {
  final bool setup;
  final bool disableRedirect;

  LoginScreen({Key key, this.setup = false, this.disableRedirect = false}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  bool _error = false;
  bool _codeReady = false;
  String _errorReason = '';
  String _state = randomAlphaNumeric(16);
  InAppWebView _loginWebView;

  @override
  void initState() { 
    // this._loginAppBrowser = new LoginAppBrowser();
    super.initState();
    this.loginToReddit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: this._error ? Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'Oops!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55),
                )
              ),
              Expanded(child: Container(),
                flex: 1,
              ),
              Hero(
                tag: 'SetupHelloGif',
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: MediaQuery.of(context).size.width * 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.asset(
                      'assets/gifs/whyDontShitWork.webp'
                    ),
                  ),
                ),
              ),
              Expanded(child: Container(),
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Something went wrong while logging in! :( We asked our robot and it told us: "' + _errorReason + 
                  '" Why don\'t you try again?',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.lerp(Colors.white, Colors.grey, 0.25),
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Expanded(child: Container(),
                flex: 5,
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return LoginScreen(setup: widget.setup, disableRedirect: true); }));
                },
                child: Text('Try again'),
              ),
              Expanded(child: Container(),
                flex: 1,
              ),
            ],
          ),
        ) : _loginWebView ?? Text('Loading...')
      ),
    );
  }

  void loginToReddit() {

    Function login = () {

      if(!SettingsService.getKey('setupDone') && !widget.setup && !widget.disableRedirect) {
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return WelcomeSetupScreen(); }));
        return;
      }

      String redditCredentials = SettingsService.getKey('redditCredentials');

      if(redditCredentials != '' && !widget.setup) {

        try {
          RedditService.reddit = Reddit.restoreInstalledAuthenticatedInstance(
            redditCredentials,
            clientId: 'yG99FCjMF8tXaA',
            userAgent: SettingsService.getKey('redditUserAgent'),
          );
          SettingsService.setKey('redditCredentials', RedditService.reddit.auth.credentials.toJson());
          SettingsService.save();
          if(widget.setup) {
            Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return ReadySetupScreen(); }));
          } else {
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return HomeScreen(); }));
          }
        } catch (e) {
          SettingsService.setKey('redditCredentials', ''); SettingsService.save();
          Future.delayed(Duration(milliseconds: 200)).then((_) {
            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return LoginScreen(setup: widget.setup); }));
          });
        }
        

      } else {

        RedditService.reddit = Reddit.createInstalledFlowInstance(
          clientId: 'yG99FCjMF8tXaA',
          userAgent: randomAlphaNumeric(10),
          redirectUri: Uri.parse('https://thatseliyt.de/')
        );

        final String authUrl = RedditService.reddit.auth.url(['*'], this._state, compactLogin: true).toString();
        setState(() {
          this._loginWebView = new InAppWebView(
            initialUrl: authUrl,
            onLoadStart: (InAppWebViewController controller, String url) {
              if(url.toString().contains('code=')) {
                String code = url.toString().replaceAll('https://thatseliyt.de/?state=' + this._state + '&code=', '');
                this.confirmRedditLogin(code);
                _codeReady = true;
              } else if(url.toString().contains('error')) {
                String error = url.replaceAll('https://thatseliyt.de/?state=' + this._state + '&error=', '');
                setState(() {
                  this._error = true;
                  this._errorReason = error;
                });
              }
            },
          );
        });


      }

    };

    if(SettingsService.ready) {
      login();
    } else {
      SettingsService.onReady = login;
    }


  }

  void confirmRedditLogin(String code) async {
    try {
      await RedditService.reddit.auth.authorize(code);
    } catch (e) {
      setState(() {
        this._error = true;
        this._errorReason = e;
      });
      return;
    }
    SettingsService.setKey('redditCredentials', RedditService.reddit.auth.credentials.toJson());
    SettingsService.setKey('redditUserAgent', RedditService.reddit.auth.userAgent);
    SettingsService.save();
    if(widget.setup) {
      Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return ReadySetupScreen(); }));
    } else {
      Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return HomeScreen(); }));
    }
  }

}

