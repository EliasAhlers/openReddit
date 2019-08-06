import 'package:flutter/material.dart';
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
            onPressed: () {
              SettingsService.reset();
            },
          ),
          Divider(),
          Center(child: Text('Made by ThatsEli with ❤')),
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

