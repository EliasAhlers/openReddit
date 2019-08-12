
import 'package:flutter/material.dart';

class SettingsKey {
  dynamic value;
  Type type;
  List<dynamic> options;
  bool hidden;
  String description;
  int category;

  SettingsKey( { @required this.type, this.options, @required this.value, @required this.hidden, @required this.description, @required this.category });

  void setValue(dynamic value, { BuildContext context }) {
    this.value = value;
  }

  void toggleActon({ BuildContext context }) {
    value(context ?? null);
  }

  dynamic getValue() {
    if(this.type == Function) {
      return false;
    } else {
      return value;
    }
  }
 
}
