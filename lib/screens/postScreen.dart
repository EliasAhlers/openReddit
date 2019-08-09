import 'dart:async';

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

  Future<void> getComments() async {
    Completer c = new Completer();
    widget.submission.refreshComments().then((val) {
      setState(() {
        this.comments = widget.submission.comments.comments;
      });
      c.complete();
    });
    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.submission.title),
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return this.getComments();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: <Widget>[
              this.comments != null
                ? Expanded(
                    child: CommentListWidget(
                    comments: this.comments,
                    highlightUserName: widget.submission.author,
                    leading: Column(
                      children: <Widget>[
                        PostWidget(submission: widget.submission, preview: false),
                        Divider(),
                      ],
                    )
                  ))
                : LinearProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }

}
