import 'package:draw/draw.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;

  CommentWidget({Key key, this.comment}) : super(key: key);

  _CommentWidgetState createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(widget.comment.author),
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Text(
                    widget.comment.authorFlairText != null ? widget.comment.authorFlairText : '',
                    style: TextStyle(
                      backgroundColor: Colors.blueAccent,
                      fontSize: 12
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
