import 'package:flutter/material.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:openReddit/screens/setupProcess/welcomeSetupScreen.dart';
import 'package:openReddit/services/settingsService.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({Key key}) : super(key: key);

  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  void dispose() { 
    SettingsService.save();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          for (var i = 0; i < SettingsService.categorys.length; i++)
            ExpansionTile(
              title: Text(SettingsService.categorys[i]),
              children: <Widget>[
                for(String key in SettingsService.getKeysWithCategory(i))
                  ListTile(
                    title: Text(SettingsService.getKeyDescription(key)),
                    trailing: Switch(
                      value: SettingsService.getKey(key),
                      onChanged: (bool value) {
                        setState(() {
                          SettingsService.setKey(key, value);
                        });
                      },
                    ),
                  ),
              ],
            ),
          Divider(),
          RaisedButton(
            child: Text('Reset'),
            onPressed: () async {
              SettingsService.reset();
              await SettingsService.init();
              setState(() {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) { return WelcomeSetupScreen(); }));
              });
            },
          ),
          Divider(),
          Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Made by ThatsEli with ❤'),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Text('github.com/ThatsEli'),
                    onTap: () { FlutterWebBrowser.openWebPage(url: 'https://github.com/ThatsEli'); /* TODO: unify with login browser */ },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    child: Text('twitter.com/ThatsEliYT'),
                    onTap: () { FlutterWebBrowser.openWebPage(url: 'https://twitter.com/ThatsEliYT'); /* TODO: unify with login browser */ },
                  ),
                ),
              ],
            )
          ),
          // RaisedButton(
          //   child: Text('Save'),
          //   onPressed: () {
          //     SettingsService.save();
          //   },
          // ),
          // RaisedButton(
          //   child: Text('Load'),
          //   onPressed: () async {
          //     await SettingsService.load();
          //     setState(() {
          //     });
          //   },
          // ),
        ],
      ),
    );
  }

}

