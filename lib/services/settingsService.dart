
import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class SettingsService {

  static List<String> categorys = ['Comment settings'];
  static Map<String, Map<String, dynamic>> _keys = {};
  static DatabaseFactory _dbFactory = databaseFactoryIo;
  static Database _db;
  static bool _loadedDb = false;

  static init() async {
    _keys = {
      'comment_actions_align_right': { 'value': true, 'description': 'Right align for comment actions', 'category': 0 },
    };
    if(!_loadedDb) {
      _loadedDb = true;
      Directory appDoc = await getApplicationDocumentsDirectory();
      _db = await _dbFactory.openDatabase(appDoc.path + '/settings.db');
      load();
    }
  }

  static List<String> getKeysWithCategory(int category) {
    List<String> keys = [];
    _keys.forEach((key, value) {
      if(value['category'] == category) {
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
    _keys[key]['value'] = value;
  }

  static save() {
    StoreRef store = StoreRef.main();
    _keys.forEach((key, value) async {
      store.record(key).put(_db, value['value']);
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
    _keys.forEach((key, value) async {
      store.record(key).delete(_db);
    });
  }

}
