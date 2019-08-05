import 'dart:core';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:openReddit/widgets/expandedSectionWidget.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final bool collapsed;

  CommentWidget({Key key, this.comment, this.collapsed = false})
      : super(key: key);

  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with AutomaticKeepAliveClientMixin {
  VoteState voteState;
  bool saved;
  bool actionsCollapsed = true;

  @override
  void initState() {
    this.voteState = widget.comment.vote;
    this.saved = widget.comment.saved;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: Padding(
        padding: EdgeInsets.only(left: 
          widget.comment.depth != null ? (10 * widget.comment.depth ?? 0).toDouble() : 0
        ),
        child: GestureDetector(
          onTap: () {
            setState(() {
              this.actionsCollapsed = !this.actionsCollapsed;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.comment.author,
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                    if (widget.comment.authorFlairText != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Text(
                            widget.comment.authorFlairText,
                            style: TextStyle(
                                backgroundColor: Colors.blueAccent,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    if (widget.comment.stickied)
                      Padding(
                        padding: const EdgeInsets.only(right: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Text(
                            'Stickied',
                            style: TextStyle(
                                backgroundColor: Color.lerp(
                                    Colors.greenAccent, Colors.black, 0.3),
                                fontSize: 12),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Text(
                        widget.comment.scoreHidden
                            ? '-'
                            : widget.comment.score.toString(),
                        style: TextStyle(
                            color: this.voteState == VoteState.upvoted
                                ? Colors.redAccent
                                : this.voteState == VoteState.downvoted
                                    ? Colors.blueAccent
                                    : null),
                      ),
                    )
                  ],
                ),
              ),
              if (!widget.collapsed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Text(
                    //   widget.comment.body,
                    //   textAlign: TextAlign.left,
                    //   style: TextStyle(fontSize: 17),
                    // ),
                    MarkdownBody(
                      data: widget.comment.body,
                    ),
                    ExpandedSectionWidget(
                      expand: !this.actionsCollapsed,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: <Widget>[
                            GestureDetector(
                              child: Icon(
                                Icons.arrow_upward,
                                color: this.voteState == VoteState.upvoted
                                    ? Colors.red
                                    : null,
                                size: 30,
                              ),
                              onTap: () {
                                VoteState newVoteState =
                                    this.voteState == VoteState.upvoted
                                        ? VoteState.none
                                        : VoteState.upvoted;
                                if (newVoteState == VoteState.upvoted)
                                  widget.comment.upvote();
                                else
                                  widget.comment.clearVote();
                                setState(() {
                                  this.voteState = newVoteState;
                                  this.actionsCollapsed = true;
                                });
                              },
                            ),
                            GestureDetector(
                              child: Icon(
                                Icons.arrow_downward,
                                color: this.voteState == VoteState.downvoted
                                    ? Colors.blue
                                    : null,
                                size: 30,
                              ),
                              onTap: () {
                                VoteState newVoteState =
                                    this.voteState == VoteState.downvoted
                                        ? VoteState.none
                                        : VoteState.downvoted;
                                if (newVoteState == VoteState.downvoted)
                                  widget.comment.downvote();
                                else
                                  widget.comment.clearVote();
                                setState(() {
                                  this.voteState = newVoteState;
                                  this.actionsCollapsed = true;
                                });
                              },
                            ),
                            GestureDetector(
                              child: Icon(
                                this.saved
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: this.saved ? Colors.yellow : null,
                                size: 30,
                              ),
                              onTap: () {
                                bool saved = !this.saved;
                                if (saved)
                                  widget.comment.save();
                                else
                                  widget.comment.unsave();
                                setState(() {
                                  this.saved = saved;
                                  this.actionsCollapsed = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
