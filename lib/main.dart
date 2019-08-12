import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/loginScreen.dart';
import 'package:openReddit/services/infoService.dart';
import 'package:openReddit/services/settingsService.dart';

main() {
  SettingsService.init();
  InfoService.init();
  runApp(MyApp());
} 

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DynamicTheme(
      defaultBrightness: Brightness.dark,
      data: (brightness) => new ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black87
        ),
        brightness: brightness,
      ),
      themedWidgetBuilder: (context, theme) {
        return new MaterialApp(
          title: 'openReddit',
          theme: theme,
          home: LoginScreen()
        );
      }
    );
  }
}
