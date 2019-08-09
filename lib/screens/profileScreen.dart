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
  List<Submission> _posts = [];
  List<Comment> _comments = [];

  @override
  void initState() {
    this.getRedittor();
    super.initState();
  }

  void getRedittor() async {
    if(widget.redditorRef != null) {
      Redditor populatedRedditor = await widget.redditorRef.populate();
      setState(() {
        _redditor = populatedRedditor;
      });
    } else {
      setState(() {
        _redditor = widget.redditor;
      });
    }
    this.getUserContent();
  }

  void getUserContent() async {
    List<UserContent> userContents = await _redditor.newest().toList();
    userContents.forEach((userContent) async {
      if(userContent is Submission) {
        _posts.add(userContent);
      } else if(userContent is Comment) {
        _comments.add(userContent);
      }
    });
    if(this.mounted)
    setState(() {});
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
                    if(Uri.parse(_redditor.data['icon_img'].toString()).path != '')
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              Uri.parse(
                                _redditor.data['icon_img'].toString().contains('/avatar/') ?
                                'https://www.redditstatic.com' + _redditor.data['icon_img'].toString() :
                                _redditor.data['icon_img'].toString()
                              ).path,
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
                )
              ],
            ),
            if(_posts.length == 0)
              LinearProgressIndicator(),
            if(_posts.length != 0)
              SubmissionsWidget(submissions: _posts),
            if(_comments.length == 0)
              LinearProgressIndicator(),
            if(_comments.length != 0)
              CommentListWidget(comments: _comments)
          ],
        )
      ),
    );
  }
}
