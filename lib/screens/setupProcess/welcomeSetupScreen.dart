import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/screens/setupProcess/loginSetupScreen.dart';

class WelcomeSetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Text(
                  'Welcome to openReddit!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Hero(
                  tag: 'SetupHelloGif',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: MediaQuery.of(context).size.width * 0.5,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        'https://media.giphy.com/media/26xBwdIuRJiAIqHwA/giphy.gif'
                      )
                    ),
                  ),
                )
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(
                  'All you have to do is to set a few things up. That won\'t take long, promise! 👍',
                  style: TextStyle(
                    fontSize: 25,
                    color: Color.lerp(Colors.white, Colors.grey, 0.25),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: IconButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return LoginSetupScreen(); }));
                  },
                  icon: Icon(
                    FontAwesomeIcons.arrowRight,
                    size: 40,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
