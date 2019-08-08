import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/homeScreen.dart';
import 'package:openReddit/services/settingsService.dart';

import '../loginScreen.dart';

class ReadySetupScreen extends StatelessWidget {
  const ReadySetupScreen({Key key}) : super(key: key);

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
                          'You are ready to go now',
                          style: TextStyle(
                            fontSize: 30
                          ),
                          maxLines: 2,
                        ),
                      )
                   ],
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 20),
                 child: Text(
                  'That\'s all! Didn\'t take that long, right? If there ' +
                  'are any problems, don\'t hesitate to contact us! This' +
                  ' project is open source and created by volunteers in ' +
                  'their freetime, so please keep that in mind!' +
                  '',
                  style: TextStyle(
                    fontSize: 25
                  ),
                ),
               ),
               Padding(
                 padding: const EdgeInsets.only(top: 300),
                 child: RaisedButton(
                   onPressed: () {
                     SettingsService.setKey('setupDone', true); SettingsService.save();
                     Navigator.pushReplacement(context, new CupertinoPageRoute(builder: (BuildContext context) { return HomeScreen(); }));
                   },
                   elevation: 5,
                   child: Text('Get started!'),
                 ),
               )
             ],
           ),
         ),
       ),
    );
  }
}