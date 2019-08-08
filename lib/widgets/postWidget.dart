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

import 'contentWidget.dart';

enum postExtraActions { openProfile, report }

class PostWidget extends StatefulWidget {
  final Submission submission;
  final bool preview;

  PostWidget({Key key, this.submission, this.preview = true}) : super(key: key);

  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> with AutomaticKeepAliveClientMixin {
  VoteState votedState;
  bool saved;

  @override
  void initState() {
    this.votedState = widget.submission.vote;
    this.saved = widget.submission.saved;
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      elevation: 5,
      color: Color.lerp(Colors.black, Colors.grey, 0.35),
      // type: MaterialType.card,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    if(widget.preview)
                    Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return PostScreen(submission: widget.submission,); }));
                  },
                  child: Column(
                    children: <Widget>[
                      Center(child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: ContentWidget(submission: widget.submission),
                      )),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.submission.title,
                            maxLines: 6, style: TextStyle(fontSize: 23)),
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
                            !widget.preview && widget.submission.selftext != '' ?
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: 
                              MarkdownBody(
                                data: widget.submission.selftext,
                                onTapLink: (link) {
                                  FlutterWebBrowser.openWebPage(url: link); // TODO: unify with login browser
                                },
                              ),
                            ) : Container(width: 0, height: 0),
                          ],
                        ),
                      ), 
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(FontAwesomeIcons.arrowCircleUp),
                      color: votedState == VoteState.upvoted ? Colors.red : null,
                      onPressed: () {
                        setState(() {
                          VoteState newVoteState =
                              votedState == VoteState.upvoted
                                  ? VoteState.none
                                  : VoteState.upvoted;
                          votedState = newVoteState;
                          if (newVoteState == VoteState.upvoted)
                            widget.submission.upvote();
                          else
                            widget.submission.clearVote();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.arrowCircleDown),
                      color: votedState == VoteState.downvoted ? Colors.blue : null,
                      onPressed: () {
                        setState(() {
                          VoteState newVoteState =
                              votedState == VoteState.downvoted
                                  ? VoteState.none
                                  : VoteState.downvoted;
                          votedState = newVoteState;
                          if (newVoteState == VoteState.downvoted)
                            widget.submission.downvote();
                          else
                            widget.submission.clearVote();
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(saved ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart),
                      color: saved ? Colors.yellowAccent : null,
                      onPressed: () {
                        setState(() {
                          saved = !saved;
                          if (saved)
                            widget.submission.save();
                          else
                            widget.submission.unsave();
                        });
                      },
                    ),
                    if(widget.submission.url.toString() != '')
                    IconButton(
                      icon: Icon(FontAwesomeIcons.bookOpen),
                      onPressed: () async {
                        await FlutterWebBrowser.openWebPage(url: widget.submission.url.toString()); // TODO: unify with login browser
                      },                      
                    ),
                    PopupMenuButton<postExtraActions>(
                      onSelected: (value) {
                        switch (value) {
                          case postExtraActions.openProfile:
                            Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return ProfileScreen(redditorRef: RedditService.reddit.redditor(widget.submission.author)); }));
                            break;
                          case postExtraActions.report:
                            String reason = '';
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return Material(
                                  child: Column(
                                    children: <Widget>[
                                      Text('Reason for report:'),
                                      TextField(
                                        onChanged: (newVal) { reason = newVal; },
                                      ),
                                      RaisedButton(
                                        child: Text('Report'),
                                        onPressed: () {
                                          widget.submission.report(reason);
                                          Navigator.pop(dialogContext);
                                        },
                                      )
                                    ],
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
                            child: Text('Open profile'),
                          ),
                          PopupMenuItem(
                            value: postExtraActions.report,
                            child: Text('Report'),
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
    submission.locked || submission.linkFlairText != null ? Padding(
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
