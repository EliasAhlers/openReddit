
import 'dart:async';
import 'dart:io';

import 'package:debug_mode/debug_mode.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SettingsService {

  static List<String> categorys = ['Post settings', 'Content settings', 'Comment settings'];
  static Function onReady;
  static bool ready = false;
  static Map<String, Map<String, dynamic>> _keys = {};
  static DatabaseFactory _dbFactory = databaseFactoryIo;
  static Database _db;
  static bool _loadedDb = false;

  static Future<void> init() async {
    Completer c = new Completer();
    _keys = {
      'setupDone': { 'value': false, 'hidden': true, 'description': '', 'category': 9999999 },
      'redditCredentials': { 'value': '', 'hidden': true, 'description': '', 'category': 9999999 },
      'redditUserAgent': { 'value': '', 'hidden': true, 'description': '', 'category': 9999999 },
      'content_gif_preload': { 'value': true, 'description': 'Preload gifs', 'category': 1 },
      'content_gif_loop': { 'value': true, 'description': 'Loop gifs', 'category': 1 },
      'content_videos_preload': { 'value': true, 'description': 'Preload videos', 'category': 1 },
      'content_video_loop': { 'value': true, 'description': 'Loop videos', 'category': 1 },
      'content_youtube_autoplay': { 'value': true, 'description': 'Autoplay youtube videos', 'category': 1 },
      'comment_actions_align_right': { 'value': true, 'description': 'Right align for comment actions', 'category': 2 },
    };
    if(DebugMode.isInDebugMode) {
      categorys.add('Debug');
      _keys.addAll({
        'closeDB': { 'value': () { SettingsService.close(); }, 'description': 'Close the app db', 'category': categorys.length-1 }
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
      if(value['category'] == category && value['hidden'] != true) {
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
    if(_keys[key]['value'] is Function) return false;
    return _keys[key]['value'];
  }

  static String getKeyDescription(String key) {
    if(_keys[key] == null) {
      print('Error, did not find key '+ key);
      throw Error();
    }
    return _keys[key]['description'];
  }

  static void setKey(String key, dynamic value) {
    if(_keys[key] == null) {
      print('Error, did not find key '+ key);
      throw Error();
    }
    if(_keys[key]['value'] is Function) {
      _keys[key]['value']();
      return;
    }
    _keys[key]['value'] = value;
  }

  static save() {
    StoreRef store = StoreRef.main();
    _keys.forEach((key, value) async {
      if(!(value['value'] is Function)) {
        store.record(key).put(_db, value['value']);
      }
    });
  }

  static Future<void> load() {
    Completer c = new Completer();
    StoreRef store = StoreRef.main();
    int counter = 0;
    _keys.forEach((key, value) async {
      if(await store.record(key).exists(_db)) {
        _keys[key]['value'] = await store.record(key).get(_db);
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
