import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class ProfileScreen extends StatefulWidget {

  final Redditor redditor;
  final RedditorRef redditorRef;

  ProfileScreen({Key key, this.redditor, this.redditorRef}) : super(key: key);

  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  Redditor redditor;
  List<Submission> posts = [];
  List<Comment> comments = [];

  @override
  void initState() {
    this.getRedittor();
    super.initState();
  }

  void getRedittor() async {
    if(widget.redditorRef != null) {
      Redditor populatedRedditor = await widget.redditorRef.populate();
      setState(() {
        redditor = populatedRedditor;
      });
    } else {
      setState(() {
        redditor = widget.redditor;
      });
    }
    this.getUserContent();
  }

  void getUserContent() async {
    List<UserContent> userContents = await redditor.newest().toList();
    userContents.forEach((userContent) {
      if(userContent is Submission) {
        posts.add(userContent);
      } else {
        comments.add(userContent);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if(redditor == null) 
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
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(
                            redditor.data['icon_img']
                          ),
                        )
                      ),
                    ),
                    Text(
                      'u/' + redditor.displayName,
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),

                  ],
                ),
                Text(
                  'Karma: ' + redditor.linkKarma.toString()
                ),
                Text(
                  'Commentkarma: ' + redditor.commentKarma.toString()
                )
              ],
            ),
            Text('Posts'),
            // SubmissionsWidget(submissions: posts),
            Text('Comments'),
          ],
        )
      ),
    );
  }
}
