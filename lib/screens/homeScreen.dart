import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/screens/loginScreen.dart';
import 'package:openReddit/screens/subredditScreen.dart';
import 'package:openReddit/services/redditService.dart';
import 'package:openReddit/widgets/postWidget.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Submission> submissions;
  List<Subreddit> subscribedSubreddits = <Subreddit>[];
  bool shrinkWrapEnabled = false;

  @override
  void initState() {
    this.loadFrontpage();
    this.loadSubscribedSubreddits();
    Future.delayed(Duration(milliseconds: 100)).then((x) {
      setState(() {
        this.shrinkWrapEnabled = true; // needs to be done cause of a bug destroying scroll performance
      });
    });
    super.initState();
  }
    
  void loadFrontpage() async {
    var submissions = RedditService.getSubmissions(await RedditService.reddit.front.best(params: { 'limit': '100' }).toList());
    setState(() {
      this.submissions = submissions;
    });
  }

  void loadPopular() async {
    var submissions = RedditService.getSubmissions(await RedditService.reddit.front.top(timeFilter: TimeFilter.day, params: { 'limit': '100' }).toList());
    setState(() {
      this.submissions = submissions;
    });
  }

  void loadSaved() async {
    Redditor me = await RedditService.reddit.user.me();
    var submissions = RedditService.getSubmissions(await me.saved().toList());
    setState(() {
      this.submissions = submissions;
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
                    onTap: () {},
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
                shrinkWrap: this.shrinkWrapEnabled,
                cacheExtent: 20,
                itemBuilder: (BuildContext context, int index) {
                  if(this.subscribedSubreddits[index] != null) {
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
                              this.subscribedSubreddits[index].iconImage.toString() ?? ''
                            ),
                          )
                        ),
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
      body: this.submissions != null ?
        SubmissionsWidget(submissions: this.submissions) : Text('Loading...'),
    );
  }
    
}