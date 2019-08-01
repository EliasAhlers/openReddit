import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:redditclient/screens/postScreen.dart';

class PostWidget extends StatefulWidget {
  final Submission submission;
  final bool preview;

  PostWidget({Key key, this.submission, this.preview}) : super(key: key);

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
                            maxLines: 3, style: TextStyle(fontSize: 25)),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'r/' + widget.submission.subreddit.displayName,
                                style: TextStyle(
                                    fontSize: 15, color: Colors.redAccent),
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
                        Row(
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
                      GestureDetector(
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
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
                      GestureDetector(
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
