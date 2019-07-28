import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/postWidget.dart';
import 'package:redditclient/widgets/commentWidget.dart';

class PostScreen extends StatefulWidget {
  final Submission submission;

  PostScreen({Key key, this.submission}) : super(key: key);

  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<Comment> comments;

  @override
  void initState() {
    this.getComments();
    super.initState();
  }

  void getComments() async {
    await widget.submission.refreshComments();
    List<Comment> commentsList = <Comment>[];
    widget.submission.comments.comments.toList().forEach((comment) {
      if(comment is Comment) {
        commentsList.add(comment);
      }
    });
    setState(() {
      this.comments = commentsList;
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
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: this.comments.length,
                itemBuilder: (BuildContext context, int index) {
                  return CommentWidget(comment: this.comments[index]);
                }
              ) : Container(width: 0, height: 0),
           ],
         ),
       ),
    );
  }
}
