import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/widgets/postWidget.dart';
import 'package:openReddit/widgets/subredditPreviewWidget.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  List<Subreddit> _subreddits = [];
  List<Submission> _submissions = [];

  StreamSubscription<SubredditRef> _subredditSubscription;
  // StreamSubscription<UserContent> _submissionSubscription;

  void _search(String query) {
    _subreddits = [];
    _submissions = [];
    _subredditSubscription = RedditService.reddit.subreddits.search(query, limit: 5).listen((subreddit) {
      setState(() {
        _subreddits.add(subreddit);
      });
    });
    // _submissionSubscription = RedditService.reddit.subreddit('all').search(query).listen((post) {
    //   setState(() {
    //     _submissions.add(post);
    //   });
    // });
  }

  @override
  void dispose() {
    if(_subredditSubscription != null)
      _subredditSubscription.cancel();
    // if(_subredditSubscription != null)
    //   _subredditSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: 
        Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                onSubmitted: (String value) {
                  _search(value);
                },
              ),
              Divider(),
              Text(
                'Subreddits',
                style: TextStyle(
                  fontSize: 35,
                ),
              ),
              _subreddits.length != 0 ? ListView.separated(
                shrinkWrap: true,
                // physics: NeverScrollableScrollPhysics(),
                itemCount: _subreddits.length,
                itemBuilder: (BuildContext context, int index) {
                  return SubredditPreviewWidget(subredditRef: _subreddits[index]);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ) : Container(),
              Divider(),
              // Text(
              //   'Posts',
              //   style: TextStyle(
              //     fontSize: 35,
              //   ),
              // ),
              // _submissions.length != 0 ? ListView.builder(
              //   shrinkWrap: true,
              //   // physics: NeverScrollableScrollPhysics(),
              //   itemCount: _submissions.length,
              //   itemBuilder: (BuildContext context, int index) {
              //     return PostWidget(submission: _submissions[index]);
              //   },
              // ) : Container(),
            ],
          ),
        )
    );
  }
}
