import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/homeScreen.dart';
import 'package:openReddit/screens/setupProcess/loginSetupScreen.dart';
import 'package:openReddit/screens/setupProcess/readySetupScreen.dart';
import 'package:openReddit/screens/setupProcess/welcomeSetupScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:openReddit/tools/LoginAppBrowser.dart';
import 'package:random_string/random_string.dart';

class LoginScreen extends StatefulWidget {
  final bool setup;

  LoginScreen({Key key, this.setup = false}) : super(key: key);

  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  
  bool error = false;
  String errorText = '';
  String errorReason = '';
  String state = randomAlphaNumeric(16);
  LoginAppBrowser loginAppBrowser;

  @override
  void initState() { 
    this.loginAppBrowser = new LoginAppBrowser();
    this.loginToReddit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: this.error ? Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Text(
                  'Oops!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 55),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Hero(
                  tag: 'SetupHelloGif',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.width * 0.6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        'https://media.giphy.com/media/Rkis28kMJd1aE/giphy.gif'
                      )
                    ),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'Something went wrong while logging in! We asked our robot and it told us: ' + errorReason + 
                  'Why don\'t you try again?',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.lerp(Colors.white, Colors.grey, 0.25),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return LoginSetupScreen(); }));
                  },
                  child: Text('Try again'),
                ),
              )
            ],
          ),
        ),
      ) : Text('If you see this, the dev fucked up. Sorry :)'),
    );
  }

  void loginToReddit() {

    Function login = () {

      if(!SettingsService.getKey('setupDone') && !widget.setup) {
        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return WelcomeSetupScreen(); }));
        return;
      }

      String redditCredentials = SettingsService.getKey('redditCredentials');

      if(redditCredentials != '' && !widget.setup) {

        try {
          RedditService.reddit = Reddit.restoreAuthenticatedInstance(
            redditCredentials,
            clientId: 'yG99FCjMF8tXaA',
            userAgent: SettingsService.getKey('redditUserAgent'),
            redirectUri: Uri.parse('https://thatseliyt.de/')
          );
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

        final String authUrl = RedditService.reddit.auth.url(['*'], this.state, compactLogin: true).toString();
        this.loginAppBrowser.setCallbacks(
          codeCallback: (String code) {
            this.confirmRedditLogin(code);
          },
          errorCallback: (String errorReason) {
            setState(() {
              this.error = true;
              this.errorText = 'Error while authenticating, please try again.';
              this.errorReason = errorReason;
            });
          },
          state: this.state
        );
        this.loginAppBrowser.open(
          url: authUrl,
          options: {
            'transparentBackground': true,
            'toolbarTop': false
          }
        );

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
      this.loginAppBrowser.close();
      setState(() {
        this.error = true;
        this.errorText = 'Error while authenticating! Please try again'; 
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

