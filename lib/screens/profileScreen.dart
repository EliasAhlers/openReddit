import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/widgets/ageWidget.dart';
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
                Expanded(flex: 1, child: Container(width: 0, height: 0)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'u/' + _redditor.displayName,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      ),
                    ),

                  ],
                ),
                Expanded(flex: 1, child: Container(width: 0, height: 0)),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            'Karma:',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (_redditor.linkKarma + _redditor.commentKarma).toString(),
                            style: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            'Age:',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          AgeWidget(
                            date: _redditor.createdUtc,
                            textStyle: TextStyle(
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text('Commentkarma: ' + _redditor.commentKarma.toString()),
                          Text('Linkkarma: ' + _redditor.linkKarma.toString()),
                        ],
                      ),
                      Column(
                        children: <Widget>[
                          Text('Exact age: ' + DateTime.now().difference(_redditor.createdUtc).inDays.toString() + ' Days'),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: FutureBuilder(
                    future: _redditor.trophies(),
                    builder: (BuildContext context, AsyncSnapshot<List<Trophy>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return Container(width: 0, height: 0);
                        case ConnectionState.active:
                          return Container(width: 0, height: 0);
                        case ConnectionState.waiting:
                          return LinearProgressIndicator();
                        case ConnectionState.done:
                          if (snapshot.hasError)
                            return Text('Error: ${snapshot.error}');
                          else return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              for (var trophy in snapshot.data)
                                Image.network(trophy.icon_70)
                            ],
                          );
                      }
                      return null;
                    },
                  ),
                ),
                Divider(),
                Expanded(flex: 10, child: Container(width: 0, height: 0)),
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
