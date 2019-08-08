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
      itemCount: submissions.length + 1,
      cacheExtent: 10,
      itemBuilder: (BuildContext context, int index) {
        if(index == 0 && widget.leading != null) {
          return widget.leading;
        }
        if(index+5 < submissions.length-1) {
          if(submissions[index+5].preview.length > 0) {
            precacheImage(NetworkImage(submissions[index+5].preview.elementAt(0).source.url.toString()), context);
          }
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: PostWidget(submission: submissions[index+1], preview: true),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider();
      },
    );
  }
}
