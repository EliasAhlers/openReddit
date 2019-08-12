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
                    trailing: this._getSettingkeyWidget(key),
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
        ],
      ),
    );
  }

  Widget _getSettingkeyWidget(String key) {
    switch (SettingsService.getKeyType(key)) {
      case bool:
        return Switch(
            value: SettingsService.getKey(key),
            onChanged: (bool value) {
              setState(() {
                SettingsService.setKey(key, value);
              });
            },
          );
        break;
      case Function:
        return RaisedButton(
          child: Text('Activate'),
          onPressed: () {
            SettingsService.toggleKeyAction(key, context: context);
          },
        );
        break;
      case List:
        return DropdownButton(
          items:  SettingsService.getKeyOptions(key).map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option.toString()),
              );
            }).toList(),
            value: SettingsService.getKey(key),
            onChanged: (newVal) {
              setState(() {
                SettingsService.setKey(key, newVal);
              });
            },
        );
        break;
      default:
        return Text('This should\'t be here...');
    }
  }

}

