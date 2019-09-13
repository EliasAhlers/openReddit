import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/postWidget.dart';

class SubmissionsWidget extends StatefulWidget {
  final List<Submission> submissions;
  final Stream<UserContent> userConentStream;
  final Widget leading;

  const SubmissionsWidget({Key key, this.submissions, this.userConentStream, this.leading}) : super(key: key);

  @override
  _SubmissionsWidgetState createState() => _SubmissionsWidgetState();
}

class _SubmissionsWidgetState extends State<SubmissionsWidget> with AutomaticKeepAliveClientMixin{

  List<Submission> _submissions = [];
  StreamSubscription<UserContent> _submissionSubscription;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    if(widget.userConentStream != null) {
      _submissionSubscription = widget.userConentStream.listen((submission) {
        if(submission is Submission) {
          if(this.mounted)
          setState(() {
            _submissions.add(submission);
          });
        }
      });
    } else {
      _submissions = widget.submissions;
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _submissionSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: _submissions.length + 1,
      cacheExtent: 10,
      itemBuilder: (BuildContext context, int index) {
        if(index == 0 && widget.leading == null) return Container(width: 0, height: 0);
        if(index == 0 && widget.leading != null) {
          return widget.leading;
        }
        if(index+5 < _submissions.length-1) {
          if(_submissions[index+5].preview.length > 0) {
            precacheImage(NetworkImage(_submissions[index+5].preview.elementAt(0).source.url.toString()), context);
          }
        }
        return PostWidget(submission: _submissions[index-1], preview: true);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }

}
