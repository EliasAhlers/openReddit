import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/postWidget.dart';

class SubmissionsWidget extends StatefulWidget {
  final List<Submission> submissions;
  final Stream<UserContent> userConentStream;

  const SubmissionsWidget({Key key, this.submissions, this.userConentStream}) : super(key: key);

  @override
  _SubmissionsWidgetState createState() => _SubmissionsWidgetState();
}

class _SubmissionsWidgetState extends State<SubmissionsWidget> {

  List<Submission> submissions = [];

  @override
  void initState() {
    if(widget.userConentStream != null) {
      widget.userConentStream.listen((submission) {
        if(submission is Submission) {
          setState(() {
            submissions.add(submission);
          });
        }
      });
    } else {
      submissions = widget.submissions;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: submissions.length,
      cacheExtent: 10,
      itemBuilder: (BuildContext context, int index) {
        if(index+5 < submissions.length-1) {
          if(submissions[index+5].preview.length > 0) {
            precacheImage(NetworkImage(submissions[index+5].preview.elementAt(0).source.url.toString()), context);
          }
        }
        return PostWidget(submission: submissions[index], preview: true);
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
