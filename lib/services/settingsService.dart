
import 'dart:async';
import 'dart:io';

import 'package:debug_mode/debug_mode.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/classes/settingsKey.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SettingsService {

  static List<String> categorys = ['Posts', 'Contents', 'Comment', 'Theme'];
  static Function onReady;
  static bool ready = false;
  static Map<String, SettingsKey> _keys;
  static DatabaseFactory _dbFactory = databaseFactoryIo;
  static Database _db;
  static bool _loadedDb = false;

  static Future<void> init() async {
    Completer c = new Completer();
    _keys = {
      'setupDone': SettingsKey(type: bool, value: false, hidden: true, description: '', category: 999999),
      'redditCredentials': SettingsKey(type: String, value: '', hidden: true, description: '', category: 999999),
      'redditUserAgent': SettingsKey(type: String, value: '', hidden: true, description: '', category: 999999),
      'content_gif_preload': SettingsKey(type: bool, value: true, hidden: false, description: 'Preload gifs', category: 1),
      'content_gif_loop': SettingsKey(type: bool, value: true, hidden: false, description: 'Loop gifs', category: 1),
      'content_videos_preload': SettingsKey(type: bool, value: true, hidden: false, description: 'Preload videos', category: 1),
      'content_video_loop': SettingsKey(type: bool, value: true, hidden: false, description: 'Loop videos', category: 1),
      'content_youtube_autoplay': SettingsKey(type: bool, value: true, hidden: false, description: 'Autoplay youtub videos', category: 1),
      'comment_actions_align_right': SettingsKey(type: bool, value: true, hidden: false, description: 'Right align forcommentactions', category: 2),
      'theme_set_light': SettingsKey(type: Function, value: (BuildContext context) { DynamicTheme.of(context).setBrightness(Brightness.light); }, hidden: false, description: 'Light mode', category: 3),
      'theme_set_dark': SettingsKey(type: Function, value: (BuildContext context) { DynamicTheme.of(context).setBrightness(Brightness.dark); }, hidden: false, description: 'Dark mode', category: 3),
  };
    if(DebugMode.isInDebugMode) {
      categorys.add('Debug');
      _keys.addAll({
        'closeDB': SettingsKey(type: Function, value: () { SettingsService.close(); }, hidden: false, description: 'Close the ddatabase', category: categorys.length-1),
      });
    }
    if(!_loadedDb) {
      _loadedDb = true;
      Directory appDoc = await getApplicationDocumentsDirectory();
      _db = await _dbFactory.openDatabase(appDoc.path + '/settings.db');
      await load();
      c.complete();
      ready = true;
      if(onReady != null)
      onReady();
    }
    return c.future;
  }

  static List<String> getKeysWithCategory(int category) {
    List<String> keys = [];
    _keys.forEach((key, value) {
      if(value.category == category && value.hidden != true) {
        keys.add(key);
      }
    });
    return keys;
  }

  static dynamic getKey(String key) {
    if(_keys[key] == null) {
      print('Error, did not find key '+ key);
      throw Error();
    }
    return _keys[key].getValue();
  }

  static String getKeyDescription(String key) {
    if(_keys[key] == null) {
      print('Error, did not find key '+ key);
      throw Error();
    }
    return _keys[key].description;
  }

  static void setKey(String key, dynamic value, { BuildContext context }) {
    if(_keys[key] == null) {
      print('Error, did not find key '+ key);
      throw Error();
    }
    _keys[key].setValue(value, context: context);
  }

  static save() {
    StoreRef store = StoreRef.main();
    _keys.forEach((key, value) async {
      if(!(value.value is Function)) {
        store.record(key).put(_db, value.getValue());
      }
    });
  }

  static Future<void> load() {
    Completer c = new Completer();
    StoreRef store = StoreRef.main();
    int counter = 0;
    _keys.forEach((key, value) async {
      if(await store.record(key).exists(_db)) {
        _keys[key].setValue(await store.record(key) .get(_db));
      }
      counter++;
      if(counter == _keys.length) c.complete();
    });
    return c.future;
  }

  static void reset() {
    StoreRef store = StoreRef.main();
    _keys.forEach((key, value) {
      store.record(key).delete(_db);
    });
    _db.close();
    ready = false;
    return;
  }

  static void close() async {
    await _db.close();
  }

}
