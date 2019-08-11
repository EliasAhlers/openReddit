import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/services/settingsService.dart';

import '../homeScreen.dart';

class ReadySetupScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'You are ready now',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),
                  textAlign: TextAlign.left,
                ),
              ),
              Expanded(child: Container(),
                flex: 2,
              ),
              Hero(
                tag: 'SetupHelloGif',
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      'https://media.giphy.com/media/CjmvTCZf2U3p09Cn0h/giphy.gif'
                    )
                  ),
                ),
              ),
              Expanded(child: Container(),
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'That\'s all! Didn\'t take that long, right? If there ' +
                  'are any problems, don\'t hesitate to contact us! This' +
                  ' project is open source and created by volunteers in ' +
                  'their freetime, so please keep that in mind!' +
                  '',
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
                  SettingsService.setKey('setupDone', true);
                  SettingsService.save();
                  Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return HomeScreen(); }));
                },
                elevation: 5,
                child: Text('Get started!'),
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
