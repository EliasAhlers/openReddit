
import 'package:flutter/material.dart';

class SettingsKey {
  dynamic value;
  Type type;
  bool hidden;
  String description;
  int category;

  SettingsKey( { @required this.type, @required this.value, @required this.hidden, @required this.description, @required this.category });

  void setValue(dynamic value, { BuildContext context }) {
    if(type == Function) {
      value(context);
    } else {
      this.value = value;
    }
  }

  dynamic getValue() {
    if(this.type == Function) {
      return false;
    } else {
      return value;
    }
  }
 
}
