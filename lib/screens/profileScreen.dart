import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/commentListWidget.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class ProfileScreen extends StatefulWidget {

  final Redditor redditor;
  final RedditorRef redditorRef;

  ProfileScreen({Key key, this.redditor, this.redditorRef}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Redditor _redditor;
  bool _postStreamReady = false;
  bool _commentStreamReady = false;

  @override
  void initState() {
    this._getRedittor();
    super.initState();
  }

  void _getRedittor() async {
    if(widget.redditorRef != null) {
      Redditor populatedRedditor = await widget.redditorRef.populate();
      setState(() {
        _redditor = populatedRedditor;
        _postStreamReady = true;
        _commentStreamReady = true;
      });
    } else {
      setState(() {
        _redditor = widget.redditor;
        _postStreamReady = true;
        _commentStreamReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(_redditor == null) 
    return Scaffold(
      body: Center(
        child: Text('Loading...'),
      ),
    );
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          bottom: TabBar(
            tabs: <Widget>[
              Tab(text: 'About'),
              Tab(text: 'Posts'),
              Tab(text: 'Comments'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    if(_redditor.data['icon_img'].toString() != '')
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              _redditor.data['icon_img'].toString().contains('/avatars/') && !_redditor.data['icon_img'].toString().contains('www.redditstatic.com') ?
                              'https://www.redditstatic.com' + _redditor.data['icon_img'].toString().split(':').first :
                              _redditor.data['icon_img'].toString().split('?').first,
                            ),
                          )
                        ),
                      ),
                    Text(
                      'u/' + _redditor.displayName,
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),

                  ],
                ),
                Text(
                  'Karma: ' + _redditor.linkKarma.toString()
                ),
                Text(
                  'Commentkarma: ' + _redditor.commentKarma.toString()
                ),
                Text(
                  'Age: ' + (DateTime.now().difference(_redditor.createdUtc).inDays / 365).round().toString()  + ' Years ' +
                  (DateTime.now().difference(_redditor.createdUtc).inDays % 365).toString()  + ' Days',
                ),
              ],
            ),
            if(!_postStreamReady)
              LinearProgressIndicator(),
            if(_postStreamReady)
              SubmissionsWidget(userConentStream: _redditor.newest()),
            if(!_commentStreamReady)
              LinearProgressIndicator(),
            if(_commentStreamReady)
              CommentListWidget(commentStream: _redditor.comments.newest().cast<Comment>()),
          ],
        )
      ),
    );
  }
}
