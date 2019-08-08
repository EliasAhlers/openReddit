import 'package:draw/draw.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/homeScreen.dart';
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
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
                            Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return LoginScreen(setup: widget.setup); }));
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

