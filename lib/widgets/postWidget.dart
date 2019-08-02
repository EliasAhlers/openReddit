import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:redditclient/screens/postScreen.dart';
import 'package:redditclient/screens/subredditScreen.dart';

class PostWidget extends StatefulWidget {
  final Submission submission;
  final bool preview;

  PostWidget({Key key, this.submission, this.preview = true}) : super(key: key);

  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  VoteState votedState;
  bool saved;
  bool showSpoiler = false;

  @override
  void initState() {
    this.votedState = widget.submission.vote;
    this.saved = widget.submission.saved;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = (widget.submission.preview.length > 0)
        ? widget.submission.preview.elementAt(0).source.url.toString()
        : '';

    return Material(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        imageUrl != ''
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    this.showSpoiler = !this.showSpoiler;
                                  });
                                },
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  color: widget.submission.spoiler && !this.showSpoiler ? Color.lerp(Colors.black, Colors.redAccent, 0.5) : null,
                                  height:
                                      MediaQuery.of(context).size.width * 0.56279,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ) : Container(width: 0, height: 0),
                        Text(widget.submission.title,
                            maxLines: 6, style: TextStyle(fontSize: 23)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () async {
                                  Subreddit subreddit = await widget.submission.subreddit.populate();
                                  Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return SubredditScreen(subreddit: subreddit); }));
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
                              Text(
                                'u/' + widget.submission.author,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.blueAccent),
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
                          child: Text(
                            widget.submission.selftext,
                            style: TextStyle(
                              fontSize: 20
                            ),
                          ),
                        ) : Container(width: 0, height: 0),
                      ],
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          child: Icon(
                            Icons.arrow_upward,
                            color: this.votedState == VoteState.upvoted
                                ? Colors.red
                                : null,
                            size: 30,
                          ),
                          onTap: () {
                            setState(() {
                              VoteState newVoteState =
                                  this.votedState == VoteState.upvoted
                                      ? VoteState.none
                                      : VoteState.upvoted;
                              this.votedState = newVoteState;
                              if (newVoteState == VoteState.upvoted)
                                widget.submission.upvote();
                              else
                                widget.submission.clearVote();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          child: Icon(Icons.arrow_downward,
                              color: this.votedState == VoteState.downvoted
                                  ? Colors.blue
                                  : null,
                              size: 30),
                          onTap: () {
                            setState(() {
                              VoteState newVoteState =
                                  this.votedState == VoteState.downvoted
                                      ? VoteState.none
                                      : VoteState.downvoted;
                              this.votedState = newVoteState;
                              if (newVoteState == VoteState.downvoted)
                                widget.submission.downvote();
                              else
                                widget.submission.clearVote();
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: GestureDetector(
                          child: Icon(
                              this.saved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: this.saved ? Colors.yellow : null,
                              size: 30),
                          onTap: () {
                            setState(() {
                              if (this.saved) {
                                widget.submission.unsave();
                                this.saved = false;
                              } else {
                                widget.submission.save();
                                this.saved = true;
                              }
                            });
                          },
                        ),
                      ),
                      if(widget.submission.url != null)
                      GestureDetector(
                        child: Icon(
                            Icons.open_in_browser,
                            size: 30
                        ),
                        onTap: () async {
                          await FlutterWebBrowser.openWebPage(url: widget.submission.url.toString()); // TODO: unify with login browser
                        },
                      )
                    ],
                  )
                ],
              )
            ],
          ),
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
