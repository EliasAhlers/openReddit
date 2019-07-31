import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/postWidget.dart';

class SubmissionsWidget extends StatefulWidget {
  final List<Submission> submissions;

  const SubmissionsWidget({Key key, this.submissions}) : super(key: key);

  @override
  _SubmissionsWidgetState createState() => _SubmissionsWidgetState();
}

class _SubmissionsWidgetState extends State<SubmissionsWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.widget.submissions.length,
      cacheExtent: 10,
      itemBuilder: (BuildContext context, int index) {
        if(index % 2 == 1) {
          return PostWidget(submission: this.widget.submissions[index~/2 + 1], preview: true);
        } else {
          return Divider();
        }
      }
    );
  }
}
