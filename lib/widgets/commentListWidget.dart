
import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:vibration/vibration.dart';

import 'commentWidget.dart';
import 'moreCommentsWidget.dart';

class CommentListWidget extends StatefulWidget {
  final List<dynamic> comments;
  final Stream<Comment> commentStream;
  final Widget leading;
  final bool noScroll;
  final String highlightUserName;

  CommentListWidget({Key key, this.comments, this.commentStream, this.leading, this.noScroll = false, this.highlightUserName = ''}) : super(key: key);

  _CommentListWidgetState createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {

  List<dynamic> _comments = [];
  List<String> _collapsedComments = [];
  List<String> _hiddenComments = [];
  StreamSubscription _commentSubscription;

  @override
  void initState() {
    this._prepareComments();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if(_commentSubscription != null) _commentSubscription.cancel();
  }

  void _prepareComments() {
    if(widget.leading != null) {
      _comments.add(widget.leading);
    }
    if(widget.comments != null) {
      for(var comment in widget.comments) {
        if(comment is Comment) {
          _processComment(comment, false);
        }
      }
    } else if(widget.commentStream != null) {
      _commentSubscription = widget.commentStream.listen((Comment comment) {
        if(comment is Comment) {
          _processComment(comment, false);
        }
      });
    }
  }

  void _processComment(Comment comment, bool hidden) {
    _comments.add(comment);
    if(comment is Comment) {
      if(comment.score < 0 || hidden) _collapsedComments.add(comment.id);
      if(comment.replies != null) {
        if(comment.replies.comments != null || comment.replies.comments.length > 0) {
          for(var reply in comment.replies.comments) {
            if(reply is Comment) {
              _processComment(reply, hidden || comment.score < 0);
            }
          }
        }
      }
    }
  }

  List<Comment> _getChildComments(Comment comment) {
    List<Comment> childComments = [];
    if(comment is Comment) {
      if(comment.replies != null) {
        if(comment.replies.comments != null || comment.replies.comments.length > 0) {
          for(var reply in comment.replies.comments) {
            if(reply is Comment) {
              childComments.addAll([reply, ..._getChildComments(reply)]);
            }
          }
        }
      }
    }
    return childComments;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemCount: this._comments.length,
        shrinkWrap: widget.noScroll,
        cacheExtent: 3,
        physics: widget.noScroll ? NeverScrollableScrollPhysics() : AlwaysScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          if(widget.leading != null && index == 0) {
            return widget.leading;
          }
          dynamic com = this._comments[index];
          if(com is Comment) {
            return GestureDetector(
              onLongPress: () async {
                if(_collapsedComments.contains(com.id)) {
                  _collapsedComments.remove(com.id);
                  _getChildComments(com).map((mapComment) {
                    return mapComment.id;
                  }).forEach((commentId) {
                    _hiddenComments.remove(commentId);
                  });
                  if(SettingsService.getKey('comment_hide_vibrate'))
                    Vibration.vibrate(duration: 100);
                  setState(() {});
                } else {
                  _collapsedComments.add(com.id);
                  _hiddenComments.addAll(_getChildComments(com).map((mapComment) {
                    return mapComment.id;
                  }));
                  if(SettingsService.getKey('comment_hide_vibrate'))
                    Vibration.vibrate(duration: 100);
                  setState(() {});
                }
              },
              onTap: () {},
              child: !_hiddenComments.contains(com.id) ? 
              CommentWidget(
                comment: com,
                highlightAuthor: com.author == widget.highlightUserName,
                collapsed: _collapsedComments.contains(com.id),
                onReply: (Comment replyComment) async {
                  await replyComment.refresh();
                  setState(() {
                    _comments.insert(index + 1, replyComment);
                  });
                },
              ) : Container(width: 0, height: 0),
            );
          } else {
            return !_hiddenComments.contains(com.id) ? MoreCommentsWidget(
              moreComments: com,
              depth: _comments[index-1] != null ? _comments[index-1].depth : 0,
            ) : Container(width: 0, height: 0);
          }
        },
      ),
    );
  }
}
