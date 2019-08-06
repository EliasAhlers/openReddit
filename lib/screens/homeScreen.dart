import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/loginScreen.dart';
import 'package:openReddit/screens/profileScreen.dart';
import 'package:openReddit/screens/subredditScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Submission> submissions = [];
  List<Subreddit> subscribedSubreddits = <Subreddit>[];

  @override
  void initState() {
    this.loadFrontpage();
    this.loadSubscribedSubreddits();
    super.initState();
  }
    
  void loadFrontpage() async {
    setState(() {
      this.submissions = [];
    });
    RedditService.reddit.front.best().listen((submission) {
      setState(() {
        this.submissions.add(submission);
      });
    });
  }

  void loadPopular() async {
    setState(() {
      this.submissions = [];
    });
    RedditService.reddit.front.top(timeFilter: TimeFilter.day).listen((submission) {
      setState(() {
        this.submissions.add(submission);
      });
    });
  }

  void loadSaved() async {
    setState(() {
      this.submissions = [];
    });
    Redditor me = await RedditService.reddit.user.me();
    me.saved().listen((submission) {
      setState(() {
        this.submissions.add(submission);
      });
    });
  }

  void loadSubscribedSubreddits() {
    RedditService.reddit.user.subreddits().listen((Subreddit subreddit) {
      setState(() {
        this.subscribedSubreddits.add(subreddit);
      });
    });
    return;
  }
    
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget> [
            // DrawerHeader(
            //   child: Text('Reddit'),
            //   margin: EdgeInsets.all(0),
            // ),
            FutureBuilder(
              future: RedditService.reddit.user.me(),
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  Redditor me = snapshot.data;
                  return ListTile(
                    title: Text(me.displayName ?? 'Loading...'),
                    trailing: RaisedButton(
                      child: Text('Logout'),
                      onPressed: () {
                        Navigator.pushReplacement(context, new MaterialPageRoute(builder: (BuildContext context) { return LoginScreen(); }));
                      },
                    ),
                    onTap: () {
                      Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return ProfileScreen(redditor: snapshot.data); }));
                    },
                  );
                } else return ListTile(title: Text('Loading...'));
              },
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                setState(() {
                  this.submissions = null;
                });
                Navigator.pop(context);
                this.loadFrontpage();
              },
            ),
            ListTile(
              title: Text('Popular'),
              onTap: () {
                setState(() {
                  this.submissions = null;
                });
                Navigator.pop(context);
                this.loadPopular();
              },
            ),
            ListTile(
              title: Text('Saved'),
              onTap: () {
                setState(() {
                  this.submissions = null;
                });
                Navigator.pop(context);
                this.loadSaved();
              },
            ),
            Divider(),
            this.subscribedSubreddits != null ?
              Expanded(child: ListView.builder(
                itemCount: this.subscribedSubreddits.length,
                addAutomaticKeepAlives: true,
                cacheExtent: 10,
                itemBuilder: (BuildContext context, int index) {
                  if(this.subscribedSubreddits[index] != null) {
                    if(this.subscribedSubreddits[index].iconImage != null && this.subscribedSubreddits[index].iconImage.toString() != '') 
                      return ListTile(
                        title: Text(this.subscribedSubreddits[index].displayName ?? 'Error while loading'),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                this.subscribedSubreddits[index].iconImage.toString()
                              ),
                            )
                          ),
                        ),
                        onTap: () {
                          Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return SubredditScreen(subreddit: this.subscribedSubreddits[index]); }));
                        },
                      );
                    else return ListTile(
                      title: Text(this.subscribedSubreddits[index].displayName ?? 'Error while loading'),
                      leading: Container(
                        width: 40,
                        height: 40,
                      ),
                      onTap: () {
                        Navigator.push(context, new MaterialPageRoute(builder: (BuildContext context) { return SubredditScreen(subreddit: this.subscribedSubreddits[index]); }));
                      },
                    ); 
                  } else return Container(width: 0, height: 0);
                }
              )) 
            : ListTile(title: Text('Loading...')),
            Divider(),
            ListTile(
              title: Text('Settings & About'),
              onTap: () {},
            ),
          ],
        )
      ),
      appBar: AppBar(
        title: Text('Reddit'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: this.submissions.length > 0 ?
          SubmissionsWidget(submissions: this.submissions) : LinearProgressIndicator(),
      ),
    );
  }
    
}