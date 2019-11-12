import 'dart:ui';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/screens/postScreen.dart';
import 'package:openReddit/screens/profileScreen.dart';
import 'package:openReddit/screens/subredditScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:openReddit/widgets/ageWidget.dart';
import 'package:share/share.dart';

import 'contentWidget.dart';

enum postExtraActions { openProfile, shareTitleAndLink, shareLink, report }

class PostWidget extends StatefulWidget {
  final Submission submission;
  final bool preview;
  final Function onReply;

  PostWidget({Key key, this.submission, this.preview = true, this.onReply}) : super(key: key);

  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with AutomaticKeepAliveClientMixin {
  VoteState _votedState;
  bool _saved;

  @override
  void initState() {
    this._votedState = widget.submission.vote;
    this._saved = widget.submission.saved;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Material(
      child: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if(widget.preview)
                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return PostScreen(submission: widget.submission); }));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: Text(
                        widget.submission.title,
                        maxLines: 6,
                        style: TextStyle(fontSize: 18)
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return SubredditScreen(futureSubreddit: widget.submission.subreddit.populate()); }));
                                  },
                                  child: Text(
                                    'r/' + widget.submission.subreddit.displayName,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                  ),
                                ),
                                Text(
                                  ' - ',
                                  style: TextStyle(fontSize: 15),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return ProfileScreen(redditorRef: RedditService.reddit.redditor(widget.submission.author)); }));
                                  },
                                  child: Text(
                                    'u/' + widget.submission.author,
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.blueAccent),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: Text(widget.submission.url.host),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: AgeWidget(date: widget.submission.createdUtc),
                                )
                              ],
                            ),
                          ),
                          PostflairWidget(widget: this.widget),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  widget.submission.upvotes.toString() + ' Votes',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  ' - ',
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text(
                                  widget.submission.numComments.toString() +
                                      ' Comments',
                                  style: TextStyle(fontSize: 20),
                                )
                              ],
                            ),
                          ),
                          widget.preview && widget.submission.selftext != '' ?
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              widget.submission.selftext,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            )
                          ) : Container(width: 0, height: 0),
                          !widget.preview && widget.submission.selftext != '' ?
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: MarkdownBody(
                              data: widget.submission.selftext,
                              onTapLink: (link) {
                                FlutterWebBrowser.openWebPage(url: link); // TODO: unify with login browser
                              },
                            ),
                          ) : Container(width: 0, height: 0),
                        ],
                      ),
                    ),
                    Center(child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: widget.preview ? ContentWidget(submission: widget.submission) : Container(width: 0, height: 0),
                    )),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: 
                  SettingsService.getKey('post_actions_align') == 'Left' ? MainAxisAlignment.start : 
                  SettingsService.getKey('post_actions_align') == 'Space between' ? MainAxisAlignment.spaceBetween : 
                  MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(FontAwesomeIcons.arrowCircleUp),
                    color: _votedState == VoteState.upvoted ? Colors.red : null,
                    onPressed: () {
                      setState(() {
                        VoteState newVoteState =
                            _votedState == VoteState.upvoted
                                ? VoteState.none
                                : VoteState.upvoted;
                        _votedState = newVoteState;
                        if (newVoteState == VoteState.upvoted)
                          widget.submission.upvote();
                        else
                          widget.submission.clearVote();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.arrowCircleDown),
                    color: _votedState == VoteState.downvoted ? Colors.blue : null,
                    onPressed: () {
                      setState(() {
                        VoteState newVoteState =
                            _votedState == VoteState.downvoted
                                ? VoteState.none
                                : VoteState.downvoted;
                        _votedState = newVoteState;
                        if (newVoteState == VoteState.downvoted)
                          widget.submission.downvote();
                        else
                          widget.submission.clearVote();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(_saved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
                    color: _saved ? Colors.yellowAccent : null,
                    onPressed: () {
                      setState(() {
                        _saved = !_saved;
                        if (_saved)
                          widget.submission.save();
                        else
                          widget.submission.unsave();
                      });
                    },
                  ),
                  if(widget.submission.url.toString() != '')
                    IconButton(
                      icon: Icon(FontAwesomeIcons.globe),
                      onPressed: () async {
                        await FlutterWebBrowser.openWebPage(url: widget.submission.url.toString()); // TODO: unify with login browser
                      },                      
                    ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.bookOpen),
                    onPressed: () async {
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return PostScreen(submission: widget.submission); }));
                    },                      
                  ),
                  IconButton(
                    icon: Icon(FontAwesomeIcons.reply),
                    onPressed: () async {
                      String reply = '';
                      bool loading = false;
                      Comment replyComment = await showModalBottomSheet(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Material(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  Text('Reply:'),
                                  TextField(
                                    onChanged: (String newVal) { reply = newVal; },
                                    maxLines: null,
                                  ),
                                  !loading ? RaisedButton(
                                    child: Text('Reply'),
                                    onPressed: () async {
                                      loading = true;
                                      Comment replyComment = await widget.submission.reply(reply);
                                      Navigator.pop(dialogContext, replyComment);
                                    },
                                  ) : LinearProgressIndicator(),
                                ],
                              ),
                            ),
                          );
                        }
                      );
                      if(replyComment != null) {
                        if(widget.onReply != null) widget.onReply(replyComment);
                      }
                    },                      
                  ),
                  PopupMenuButton<postExtraActions>(
                    onSelected: (value) {
                      switch (value) {
                        case postExtraActions.openProfile:
                          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return ProfileScreen(redditorRef: RedditService.reddit.redditor(widget.submission.author)); }));
                          break;
                        case postExtraActions.shareLink:
                          Share.share(this.widget.submission.url.toString());
                          break;
                        case postExtraActions.shareTitleAndLink:
                          Share.share(this.widget.submission.title + "   " + this.widget.submission.url.toString());
                          break;
                        case postExtraActions.report:
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
                                          await widget.submission.report(reason);
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
                          value: postExtraActions.openProfile,
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
                          value: postExtraActions.shareLink,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.link),
                              ),
                              Text('Share link')
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: postExtraActions.shareTitleAndLink,
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Icon(Icons.share),
                              ),
                              Text('Share title and link')
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: postExtraActions.report,
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

                  )
                ],
              )
            ],
          )
        ],
      ),
    );
  
  }

}

class PostflairWidget extends StatelessWidget {
  const PostflairWidget({
    Key key,
    @required this.widget,
  }) : super(key: key);

  final PostWidget widget;

  @override
  Widget build(BuildContext context) {
    Submission submission = widget.submission;
    return submission.pinned || submission.stickied || submission.over18 || submission.spoiler || submission.archived ||
    submission.locked || submission.data['crosspost_parent'] != null || submission.linkFlairText != null ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          submission.pinned ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Pinned',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.greenAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.data['crosspost_parent'] != null ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Crossposted',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.orangeAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.stickied ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Stickied',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.yellowAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.over18 ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'NSFW',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.redAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.spoiler ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Spoiler',
              style: TextStyle(
                backgroundColor: Colors.grey,
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.archived ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Archived',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.orangeAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.locked ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              'Locked',
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.deepOrangeAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
          submission.linkFlairText != null ? ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: Text(
              submission.linkFlairText,
              style: TextStyle(
                backgroundColor: Color.lerp(Colors.blueAccent, Colors.black, 0.3),
              ),
            ),
          ) : Container(width: 0, height: 0),
        ],
      ),
    ) : Container(width: 0, height: 0);
  }
}
