import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Post extends StatefulWidget {
  final Submission submission;

  Post({Key key, this.submission}) : super(key: key);
  

  _PostState createState() => _PostState();
}

class _PostState extends State<Post> {

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Text(
                      widget.submission.title,
                      maxLines: 3,
                      style: TextStyle(fontSize: 25)),
                  Row(
                    children: <Widget>[
                      Text(
                        'r/' + widget.submission.subreddit.displayName,
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        ' - ',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        'u/' + widget.submission.author,
                        style: TextStyle(fontSize: 15),
                      )
                    ],
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
                        widget.submission.numComments.toString() + ' Comments',
                        style: TextStyle(fontSize: 20),
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
