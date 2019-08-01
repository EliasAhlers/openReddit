import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/moreCommentsWidget.dart';
import 'package:redditclient/widgets/postWidget.dart';
import 'package:redditclient/widgets/commentWidget.dart';

class PostScreen extends StatefulWidget {
  final Submission submission;

  PostScreen({Key key, this.submission}) : super(key: key);

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> comments;
  bool enableShrinkWrap = false;

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
    await Future.delayed(Duration(milliseconds: 100));
    setState(() {
      this.enableShrinkWrap = true; // needs to be done cause of a bug destroying scroll performance
    });  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: SingleChildScrollView(
         child: Column(
           mainAxisSize: MainAxisSize.max,
           children: <Widget>[
              PostWidget(submission: widget.submission, preview: false),
              this.comments != null ?
              ListView.builder(
                itemCount: this.comments.length,
                shrinkWrap: this.enableShrinkWrap,
                cacheExtent: 10,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  dynamic com = this.comments[index];
                  if(com is Comment) return CommentWidget(comment: com); else
                  return MoreCommentsWidget(moreComments: com, depth: this.comments[index-1].depth);
                },
              )
              : Center(
                child: Text('Loading comments...'),
              ),
           ],
         ),
       ),
    );
  }
}
