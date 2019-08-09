import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/commentListWidget.dart';

class MoreCommentsWidget extends StatefulWidget {
  final MoreComments moreComments;

  MoreCommentsWidget({Key key, this.moreComments}) : super(key: key);

  _MoreCommentsWidgetState createState() => _MoreCommentsWidgetState();
}

class _MoreCommentsWidgetState extends State<MoreCommentsWidget> {
  bool _loaded = false;
  bool _loading = false;
  List<dynamic> _loadedComments = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    if(_loaded) {
      return CommentListWidget(comments: this._loadedComments, noScroll: true);
    } else

    if(_loading) {
      return LinearProgressIndicator();
    } else 
    return RaisedButton(
      elevation: 5,
      onPressed: () async {
        setState(() {
         this._loading = true; 
        });
        MoreComments moreComments = widget.moreComments;
        List<dynamic> loadedCommentsDyn = await moreComments.comments(update: true);
        setState(() {
          this._loading = false;
          this._loaded = true;
          this._loadedComments = loadedCommentsDyn;
        });
      },
      child: Text('Load more comments(' + widget.moreComments.count.toString() + ')'),
    );
  }

}
