import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/loginScreen.dart';

class LoginSetupScreen extends StatefulWidget {
  LoginSetupScreen({Key key}) : super(key: key);

  _LoginSetupScreenState createState() => _LoginSetupScreenState();
}

class _LoginSetupScreenState extends State<LoginSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Padding(
         padding: const EdgeInsets.all(8.0),
         child: Center(
           child: Column(
             children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Hero(
                          tag: 'SetupHelloGif',
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.2,
                            height: MediaQuery.of(context).size.width * 0.2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Image.network(
                                'https://media.giphy.com/media/26xBwdIuRJiAIqHwA/giphy.gif'
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'You need to login now',
                          style: TextStyle(
                            fontSize: 30
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: Container(),
                  flex: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'You need to authenticate with Reddit to use this app. ' +
                    'We don\'t store your password in any way. You can alwa' +
                    'ys withdraw opedReddits acess. Click on the button bel' +
                    'ow to login.',
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.lerp(Colors.white, Colors.grey, 0.25),
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
                Expanded(child: Container(),
                  flex: 10,
                ),
                RaisedButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return LoginScreen(setup: true); }));
                  },
                  elevation: 5,
                  child: Text('Login to reddit'),
                ),
                Expanded(child: Container(),
                  flex: 1,
                ),
             ],
           ),
         ),
       ),
    );
  }
}