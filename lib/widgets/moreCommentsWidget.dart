import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/commentWidget.dart';

class MoreCommentsWidget extends StatefulWidget {
  final MoreComments moreComments;
  final int depth;

  MoreCommentsWidget({Key key, this.moreComments, this.depth}) : super(key: key);

  _MoreCommentsWidgetState createState() => _MoreCommentsWidgetState();
}

class _MoreCommentsWidgetState extends State<MoreCommentsWidget> {
  bool loaded = false;
  bool loading = false;
  List<dynamic> loadedComments = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    if(loaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: this.loadedComments.length,
        itemBuilder: (BuildContext context, int index) {
          dynamic comment = this.loadedComments[index];
          if(comment is Comment) {
            return CommentWidget(comment: comment);
          } else if(comment is MoreComments) {
            return MoreCommentsWidget(moreComments: comment);
          } else return Text('Error while loading this comment');
        }
      );
    } else

    if(loading) {
      return LinearProgressIndicator();
    } else 
    return ButtonTheme(
      child: RaisedButton(
        onPressed: () async {
          setState(() {
           this.loading = true; 
          });
          MoreComments moreComments = widget.moreComments;
          List<dynamic> loadedCommentsDyn = await moreComments.comments(update: true);
          setState(() {
            this.loading = false;
            this.loaded = true;
            this.loadedComments = loadedCommentsDyn;
          });
        },
        child: Text('Load more comments(' + widget.moreComments.count.toString() + ')'),
      ),
    );
  }
}
