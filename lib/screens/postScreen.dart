import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/commentListWidget.dart';
import 'package:openReddit/widgets/postWidget.dart';

class PostScreen extends StatefulWidget {
  final Submission submission;

  PostScreen({Key key, this.submission}) : super(key: key);

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> comments;
  bool enableShrinkWrap = true;

  @override
  void initState() {
    this.getComments();
    super.initState();
  }

  void getComments() async {
    await widget.submission.refreshComments();
    setState(() {
      this.comments = widget.submission.comments.comments;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Padding(
         padding: const EdgeInsets.only(left: 8.0, right: 8, top: 20),
         child: Column(
           children: <Widget>[
              this.comments != null ?
              Expanded(child: 
                CommentListWidget(
                  comments: this.comments,
                  leading: PostWidget(submission: widget.submission, preview: false),
                )
              )
              : LinearProgressIndicator(),
           ],
         ),
       ),
    );
  }
}
