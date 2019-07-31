import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:redditclient/screens/loginScreen.dart';
import 'package:redditclient/services/redditService.dart';
import 'package:redditclient/widgets/postWidget.dart';
import 'package:redditclient/widgets/submissionsWidget.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Submission> submissions;

  @override
  void initState() {
    this.loadFrontpage();
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: <Widget> [
            // DrawerHeader(
            //   child: Text('Reddit'),
            //   margin: EdgeInsets.all(0),
            // ),
            FutureBuilder(
              future: RedditService.reddit.user.me(),
              builder: (context, snapshot) {
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
              },
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                this.submissions = null;
                Navigator.pop(context);
                this.loadFrontpage();
              },
            ),
            Divider(),
            ListTile(
              title: Text('Popular'),
              onTap: () {
                this.submissions = null;
                Navigator.pop(context);
                this.loadPopular();
              },
            ),
            Divider(),
            ListTile(
              title: Text('Saved'),
              onTap: () {
                this.submissions = null;
                Navigator.pop(context);
                this.loadSaved();
              },
            ),
            Divider(),
            ListTile(
              title: Text('About'),
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