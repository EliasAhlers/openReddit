import 'dart:core';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/screens/profileScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:openReddit/widgets/ageWidget.dart';
import 'package:openReddit/widgets/expandedSectionWidget.dart';

enum commentExtraActions { openProfile, report }

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final bool collapsed;
  final bool highlightAuthor;
  final Function onReply;

  CommentWidget({Key key, this.comment, this.collapsed = false, this.highlightAuthor = false, this.onReply})
      : super(key: key);

  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget>
    with AutomaticKeepAliveClientMixin {
  VoteState _voteState;
  bool _saved;
  bool _actionsCollapsed = true;

  @override
  void initState() {
    this._voteState = widget.comment.vote;
    this._saved = widget.comment.saved;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.only(
        left: widget.comment.depth != null ? (5* widget.comment.depth ?? 0).toDouble() : 5,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: widget.comment.depth != null ?
            widget.comment.depth > 0 && SettingsService.getKey('comment_bars_enable') ? Border(
              left: BorderSide(
                color:
                  SettingsService.getKey('comment_bars_color') == 'White' ? Colors.white :
                  SettingsService.getKey('comment_bars_color') == 'Blue' ? Colors.blue :
                  SettingsService.getKey('comment_bars_color') == 'Green' ? Colors.green :
                  SettingsService.getKey('comment_bars_color') == 'Red' ? Colors.red :
                  SettingsService.getKey('comment_bars_color') == 'Brown' ? Colors.brown :
                  SettingsService.getKey('comment_bars_color') == 'Grey' ? Colors.grey :
                  Colors.grey,
                width: 2,
              ),
          ) : Border() : Border(),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              this._actionsCollapsed = !this._actionsCollapsed;
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
                        'u/' + widget.comment.author,
                        style: TextStyle(
                          color: widget.highlightAuthor ? Colors.greenAccent : Colors.blueAccent
                        ),
                      ),
                      if(widget.highlightAuthor)
                        Icon(
                          FontAwesomeIcons.microphone,
                          color: Colors.greenAccent,
                          size: 12.5,
                        ),
                      if (widget.comment.authorFlairText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
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
                          padding: const EdgeInsets.only(left: 4),
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
                              color: this._voteState == VoteState.upvoted
                                  ? Colors.redAccent
                                  : this._voteState == VoteState.downvoted
                                      ? Colors.blueAccent
                                      : null),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: AgeWidget(
                            date: widget.comment.createdUtc,
                            textStyle: TextStyle(
                              fontSize: 12,
                            ),
                            suffix: ' ago',
                          ),
                        )
                      ),
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
                        expand: !this._actionsCollapsed,
                        child: Row(
                          mainAxisAlignment:
                            SettingsService.getKey('comment_actions_align') == 'Left' ? MainAxisAlignment.start : 
                            SettingsService.getKey('comment_actions_align') == 'Space between' ? MainAxisAlignment.spaceBetween : 
                            MainAxisAlignment.end,      
                          children: <Widget>[
                            IconButton(
                              icon: Icon(FontAwesomeIcons.arrowCircleUp),
                              color: _voteState == VoteState.upvoted ? Colors.red : null,
                              onPressed: () {
                                setState(() {
                                  _actionsCollapsed = true;
                                  VoteState newVoteState =
                                      _voteState == VoteState.upvoted
                                          ? VoteState.none
                                          : VoteState.upvoted;
                                  _voteState = newVoteState;
                                  if (newVoteState == VoteState.upvoted)
                                    widget.comment.upvote();
                                  else
                                    widget.comment.clearVote();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(FontAwesomeIcons.arrowCircleDown),
                              color: _voteState == VoteState.downvoted ? Colors.blue : null,
                              onPressed: () {
                                setState(() {
                                  _actionsCollapsed = true;
                                  VoteState newVoteState =
                                      _voteState == VoteState.downvoted
                                          ? VoteState.none
                                          : VoteState.downvoted;
                                  _voteState = newVoteState;
                                  if (newVoteState == VoteState.downvoted)
                                    widget.comment.downvote();
                                  else
                                    widget.comment.clearVote();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(_saved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
                              color: _saved ? Colors.yellowAccent : null,
                              onPressed: () {
                                setState(() {
                                  _actionsCollapsed = true;
                                  _saved = !_saved;
                                  if (_saved)
                                    widget.comment.save();
                                  else
                                    widget.comment.unsave();
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(FontAwesomeIcons.reply),
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    String reply = '';
                                    return Material(
                                      child: Column(
                                        children: <Widget>[
                                          Text('Reply:'),
                                          TextField(
                                            onChanged: (String newVal) { reply = newVal; },
                                          ),
                                          RaisedButton(
                                            child: Text('Reply'),
                                            onPressed: () async {
                                              Comment replyComment = await widget.comment.reply(reply);
                                              if(widget.onReply != null) widget.onReply(replyComment);
                                              Navigator.pop(dialogContext);
                                            },
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                );
                              },
                            ),
                            PopupMenuButton<commentExtraActions>(
                              onSelected: (value) {
                                switch (value) {
                                  case commentExtraActions.openProfile:
                                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return ProfileScreen(redditorRef: RedditService.reddit.redditor(this.widget.comment.author)); }));
                                    break;
                                  case commentExtraActions.report:
                                    String reason = '';
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        return Material(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: <Widget>[
                                                Text('Reason for report:'),
                                                TextField(
                                                  onChanged: (String newVal) { reason = newVal; },
                                                  maxLines: null,
                                                ),
                                                RaisedButton(
                                                  child: Text('Report post'),
                                                  onPressed: () async {
                                                    await widget.comment.report(reason);
                                                    Navigator.pop(dialogContext);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                    );
                                    break;
                                  default:
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return [
                                  PopupMenuItem(
                                    value: commentExtraActions.openProfile,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.person),
                                        ),
                                        Text('Open profile')
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: commentExtraActions.report,
                                    child: Row(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(right: 8.0),
                                          child: Icon(Icons.flag),
                                        ),
                                        Text('Report')
                                      ],
                                    ),
                                  ),
                                ];
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
