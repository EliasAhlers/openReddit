
import 'package:flutter/material.dart';

class AgeWidget extends StatefulWidget {
  final DateTime date;
  final TextStyle textStyle;

  AgeWidget({Key key, @required this.date, this.textStyle}) : super(key: key);

  _AgeWidgetState createState() => _AgeWidgetState();
}

class _AgeWidgetState extends State<AgeWidget> {
  String _ageString = '';

  @override
  void initState() {

    _ageString = _getAgeString();
    super.initState();
  }

  String _getAgeString() {
    Duration diff = DateTime.now().difference(widget.date);

    if(diff.inHours > 8766) {
      if((diff.inDays / 365).round() == 1) return 'One Year';
      return (diff.inDays / 365).round().toString() + ' Years';
    }
    if(diff.inHours > 24) {
      if(diff.inDays == 1) return 'One Day';
      return diff.inDays.toString() + ' Days';
    }
    if(diff.inMinutes > 60) {
      if(diff.inHours == 1) return 'One Hour';
      return diff.inHours.toString() + ' Hours';
    }
    if(diff.inMinutes == 1) return 'One Minute';
    return diff.inMinutes.toString() + ' Minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _ageString,
      style: widget.textStyle ?? TextStyle()
    );
  }
}
