
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/subredditScreen.dart';

class SubredditPreviewWidget extends StatefulWidget {
  final Subreddit subreddit;
  final SubredditRef subredditRef;

  SubredditPreviewWidget({Key key, this.subreddit, this.subredditRef}) : super(key: key);

  _SubredditPreviewWidgetState createState() => _SubredditPreviewWidgetState();
}

class _SubredditPreviewWidgetState extends State<SubredditPreviewWidget> {
  Subreddit _subreddit;

  bool _ready;

  @override
  void initState() {
    _ready = false;
    _populate();
    super.initState();
  }


  void _populate() async {
    if(widget.subredditRef != null) {
      _subreddit = await widget.subredditRef.populate();
      if(this.mounted)
        setState(() {
          _ready = true;
        });
    } else {
      _subreddit = widget.subreddit;
      setState(() {
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_ready)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Material(
          type: MaterialType.card,
          borderRadius: BorderRadius.circular(5),
          child: ListTile(
            title: Text(
              'r/' + _subreddit.displayName,
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              _subreddit.data['public_description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading: _subreddit.iconImage.toString() != '' ?
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(_subreddit.iconImage.toString())
                    )
                  ),
                ) : Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                ),
            onTap: () {
              Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return SubredditScreen(subreddit: _subreddit); }));
            },
          ),
        ),
      );
    else return LinearProgressIndicator();
  }
}
