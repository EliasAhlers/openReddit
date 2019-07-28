import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/stores/redditStore.dart';
import 'package:redditclient/widgets/post.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<Submission> submissions;

  @override
  void initState() {
    this.getPosts();
    super.initState();
  }

  Future<void> getPosts() async {
    List<Submission> userContents = <Submission>[];
    await RedditStore.reddit.front.hot(params: { 'limit': '100' }).forEach((UserContent userContent) {
      userContents.add(userContent as Submission);
    });
    setState(() {
      this.submissions = userContents;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
       child: this.submissions != null ?
        ListView.builder(
          itemCount: this.submissions.length,
          itemBuilder: (BuildContext context, int index) {
            if(index % 2 == 1) {
              return Post(submission: this.submissions[index~/2 + 1]);
            } else {
              return Divider();
            }
          }
        ) : Text('Loading...'),
    );
  }
}