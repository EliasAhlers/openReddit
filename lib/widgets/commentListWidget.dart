
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

import 'commentWidget.dart';
import 'moreCommentsWidget.dart';

class CommentListWidget extends StatefulWidget {
  final List<dynamic> comments;
  final Widget leading;
  final bool noScroll;

  CommentListWidget({Key key, this.comments, this.leading, this.noScroll = false}) : super(key: key);

  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {

  List<dynamic> _comments = [];

  @override
  void initState() {
    this._processComments();
    super.initState();
  }

  void _processComments() async {
    List<dynamic> replies = [];
    if(widget.leading != null) {
      replies.add(widget.leading);
    }
    for (dynamic comment in widget.comments) {
      // if(comment is Comment) {
      //   if(comment.replies != null)
      //   replies.addAll([comment, ...comment.replies.comments]);
      // }
      replies.add(comment);
      if(comment is Comment)
      replies.addAll(this._processComment(comment));
    }
    this._comments = replies;
    // this.comments.insert(0, PostWidget(submission: widget.submission, preview: false));
    if(this.mounted) {
      setState(() {});
    }
  }

  List<dynamic> _processComment(Comment comment) {
    List<dynamic> replies = [];
    if(comment.replies != null) {
      if(comment.replies.comments != null) {
        if(comment.replies.comments.length > 0) {
          for (dynamic reply in comment.replies.comments) {
            if(reply is Comment) {
              if(reply.replies != null) {
                replies.addAll([reply, ...reply.replies.comments]);
              } else {
                replies.add(reply);
              }
            }
          }
        }
      }
    }
    return replies;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemCount: this._comments.length,
        shrinkWrap: true,
        cacheExtent: 3,
        physics: widget.noScroll ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if(widget.leading != null && index == 0) {
            return widget.leading;
          }
          dynamic com = this._comments[index];
          if(com is Comment) return CommentWidget(comment: com, showReplies: false); else
          return MoreCommentsWidget(moreComments: com, depth: this._comments[index-1].depth);
        },
      ),
    );
  }
}
