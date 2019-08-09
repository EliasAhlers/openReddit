import 'dart:core';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:openReddit/widgets/expandedSectionWidget.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final bool collapsed;
  final bool highlightAuthor;

  CommentWidget({Key key, this.comment, this.collapsed = false, this.highlightAuthor = false})
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
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
        left: widget.comment.depth != null ? (5* widget.comment.depth ?? 0).toDouble() : 0,
      ),
      child: Material(
        elevation: (1 * widget.comment.depth + 1 ?? 0).toDouble(),
        borderRadius: BorderRadius.circular(5),
        color: Color.lerp(Colors.black, Colors.grey, 0.35),
        child: Padding(
          padding: EdgeInsets.all(4),
          child: GestureDetector(
            onTap: () {
              setState(() {
                this.actionsCollapsed = !this.actionsCollapsed;
              });
            },
            child: Container(
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
                        if(widget.highlightAuthor)
                          Icon(
                            FontAwesomeIcons.microphone,
                            color: Colors.green,
                            size: 12.5,
                          ),
                        if (widget.comment.authorFlairText != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Text(
                              'Stickied',
                              style: TextStyle(
                                  backgroundColor: Color.lerp(
                                      Colors.greenAccent, Colors.black, 0.3),
                                  fontSize: 12),
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
                        MarkdownBody(
                          data: widget.comment.body,
                          onTapLink: (link) {
                            FlutterWebBrowser.openWebPage(url: link); // TODO: unify with login browser
                          },
                        ),
                        ExpandedSectionWidget(
                          expand: !this.actionsCollapsed,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                            mainAxisAlignment: SettingsService.getKey('comment_actions_align_right') ? MainAxisAlignment.end : MainAxisAlignment.start,                            
                            children: <Widget>[
                              IconButton(
                                icon: Icon(FontAwesomeIcons.arrowCircleUp),
                                color: voteState == VoteState.upvoted ? Colors.red : null,
                                onPressed: () {
                                  setState(() {
                                    actionsCollapsed = true;
                                    VoteState newVoteState =
                                        voteState == VoteState.upvoted
                                            ? VoteState.none
                                            : VoteState.upvoted;
                                    voteState = newVoteState;
                                    if (newVoteState == VoteState.upvoted)
                                      widget.comment.upvote();
                                    else
                                      widget.comment.clearVote();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(FontAwesomeIcons.arrowCircleDown),
                                color: voteState == VoteState.downvoted ? Colors.blue : null,
                                onPressed: () {
                                  setState(() {
                                    actionsCollapsed = true;
                                    VoteState newVoteState =
                                        voteState == VoteState.downvoted
                                            ? VoteState.none
                                            : VoteState.downvoted;
                                    voteState = newVoteState;
                                    if (newVoteState == VoteState.downvoted)
                                      widget.comment.downvote();
                                    else
                                      widget.comment.clearVote();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(saved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
                                color: saved ? Colors.yellowAccent : null,
                                onPressed: () {
                                  setState(() {
                                    actionsCollapsed = true;
                                    saved = !saved;
                                    if (saved)
                                      widget.comment.save();
                                    else
                                      widget.comment.unsave();
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
        ),
      ),
    );
  }
}
