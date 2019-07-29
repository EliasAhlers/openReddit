import 'dart:core';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/moreCommentsWidget.dart';


class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget({Key key, this.comment}) : super(key: key);

  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: Colors.grey,
                width: 2,
              )
            )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.comment.author,
                      style: TextStyle(
                        color: Colors.blueAccent
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Text(
                          widget.comment.authorFlairText != null ? widget.comment.authorFlairText : '',
                          style: TextStyle(
                            backgroundColor: Colors.blueAccent,
                            fontSize: 12
                          ),
                        ),
                      ),
                    ),
                    Text(widget.comment.scoreHidden ? '-' : widget.comment.score.toString())
                  ],
                ),
              ),
              Text(
                widget.comment.body,
                textAlign: TextAlign.left,
                style: TextStyle(
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: widget.comment.replies != null ? Container(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.comment.replies.comments.length,
                    itemBuilder: (BuildContext context, int index) {
                      var comment = widget.comment.replies.comments[index];
                      if(comment is Comment) {
                        return CommentWidget(comment: widget.comment.replies.comments[index]);
                      } else if(comment is MoreComments) {
                        return MoreCommentsWidget(moreComments: comment);
                      } else return Container(width: 0, height: 0);
                    }
                  ),
                ): Container(width: 0, height: 0),
              )
            ],
          ),
        ),
      ),
    );
  }

}
