
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/widgets/commentWidget.dart';

class MoreCommentsWidget extends StatefulWidget {
  final MoreComments moreComments;
  final int depth;

  MoreCommentsWidget({Key key, this.moreComments, this.depth}) : super(key: key);

  _MoreCommentsWidgetState createState() => _MoreCommentsWidgetState();
}

class _MoreCommentsWidgetState extends State<MoreCommentsWidget> {
  bool cached = false;
  List<dynamic> cachedComments = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    if(cached) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: this.cachedComments.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic comment = this.cachedComments[index];
          if(comment is Comment) {
            return CommentWidget(comment: comment);
          } else if(comment is MoreComments) {
            return MoreCommentsWidget(moreComments: comment);
          }
        }
      );
    } else
    return ButtonTheme(
      child: RaisedButton(
        onPressed: () async {
          MoreComments moreComments = widget.moreComments;
          List<dynamic> loadedCommentsDyn = await moreComments.comments(update: true);
          setState(() {
            this.cached = true;
            this.cachedComments = loadedCommentsDyn;
          });
        },
        child: Text('Load more comments(' + widget.moreComments.count.toString() + ')'),
      ),
    );
  }
}
