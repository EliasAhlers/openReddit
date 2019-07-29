import 'dart:core';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/ExpandedSectionWidget.dart';
import 'package:redditclient/widgets/moreCommentsWidget.dart';
import 'package:vibration/vibration.dart';


class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget({Key key, this.comment}) : super(key: key);

  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  VoteState voteState;
  bool saved;
  bool collapsed = false;

  @override
  void initState() {
    this.voteState = widget.comment.vote;
    this.saved = widget.comment.saved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: GestureDetector(
        onLongPress: () {
          setState(() {
            this.collapsed = !this.collapsed;
            Vibration.vibrate(duration: 100);
          });
        },
        onTap: () {
          if(this.collapsed) {
            setState(() {
              this.collapsed = false;
              Vibration.vibrate(duration: 100);
            });
          }
        },
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
                ExpandedSectionWidget(
                  expand: !this.collapsed,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.comment.body,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 17
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Icon(
                                Icons.arrow_upward,
                                color: this.voteState == VoteState.upvoted ? Colors.red : null,
                                size: 30,
                              ),
                              onTap: () {
                                VoteState newVoteState = this.voteState == VoteState.upvoted ? VoteState.none : VoteState.upvoted;
                                if (newVoteState == VoteState.upvoted) widget.comment.upvote(); else widget.comment.clearVote();
                                setState(() {
                                  this.voteState = newVoteState;
                                });
                              },
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.arrow_downward,
                                color: this.voteState == VoteState.downvoted ? Colors.blue : null,
                                size: 30,
                              ),
                              onTap: () {
                                VoteState newVoteState = this.voteState == VoteState.downvoted ? VoteState.none : VoteState.downvoted;
                                if (newVoteState == VoteState.downvoted) widget.comment.downvote(); else widget.comment.clearVote();
                                setState(() {
                                  this.voteState = newVoteState;
                                });
                              },
                            ),
                            GestureDetector(
                              child: Icon(
                                this.saved ? Icons.favorite : Icons.favorite_border,
                                color: this.saved? Colors.yellow : null,
                                size: 30,
                              ),
                              onTap: () {
                                bool saved = !this.saved;
                                if (saved) widget.comment.save(); else widget.comment.unsave();
                                setState(() {
                                  this.saved = saved;
                                });
                              },
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.format_line_spacing,
                                size: 30,
                              ),
                              onTap: () {
                                setState(() {
                                  this.collapsed = !this.collapsed;
                                  Vibration.vibrate(duration: 100);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 2),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

}
