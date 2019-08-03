
import 'dart:async';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openReddit/widgets/submissionsWidget.dart';

class SubredditScreen extends StatefulWidget {

  final Subreddit subreddit;
  final Future<Subreddit> futureSubreddit;

  SubredditScreen({Key key, this.subreddit, this.futureSubreddit}) : super(key: key);

  _SubredditScreenState createState() => _SubredditScreenState();
}

class _SubredditScreenState extends State<SubredditScreen> {
  List<UserContent> userContentList = [];
  List<Rule> rules;
  Stream<UserContent> userConent;
  String sortMethod = 'Hot';
  StreamSubscription<UserContent> newUserConentsubscription;
  bool ready = false;
  Subreddit subreddit;

  @override
  void initState() {
    this.getRules();
    this.populate();
    super.initState();
  }

  void populate() async {
    if(widget.futureSubreddit != null) {
      subreddit = await widget.futureSubreddit;
      await this.getSubmissions();
      setState(() {
        ready = true;
      });
    } else {
      subreddit = widget.subreddit;
      await this.getSubmissions();
      setState(() {
        ready = true;
      });
    }
  }

  void getRules() async {
    this.rules = await subreddit.rules();
  }

  Future<void> getSubmissions() async {
    Completer completer = new Completer();

    if(this.newUserConentsubscription != null) {
      this.newUserConentsubscription.cancel();
    }
    this.userContentList = [];
    switch (this.sortMethod) {
      case 'Hot': this.userConent = subreddit.hot(); break;
      case 'Top': this.userConent = subreddit.top(); break;
      case 'New': this.userConent = subreddit.newest(); break;
      case 'Rising': this.userConent = subreddit.rising(); break;
      case 'Controversial': this.userConent = subreddit.controversial(); break;
    }
    
    this.newUserConentsubscription = this.userConent.listen((content) async {
      setState(() {
        this.userContentList.add(content);
        completer.complete();
      });
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if(ready) {
      return Scaffold(
        endDrawer: Drawer(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(subreddit.iconImage.toString() ?? '')
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'r/' + subreddit.displayName,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  subreddit.data['public_description'],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 5),
                ),
                Text('Subreddit rules:'),
                this.rules != null ? 
                Expanded(
                  child: ListView.separated(
                    itemCount: this.rules.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(this.rules[index].shortName),
                        subtitle: Text(this.rules[index].description),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                  )
                )
                : Text('Loading rules...'),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text('r/' + subreddit.displayName),
          actions: <Widget>[
            DropdownButton(
              value: this.sortMethod,
              items: ['Top', 'Hot', 'New', 'Rising', 'Controversial'].map((String val) {
                return DropdownMenuItem(
                  value: val,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          val == 'Top' ? FontAwesomeIcons.trophy :
                          val == 'Hot' ? FontAwesomeIcons.fire :
                          val == 'New' ? FontAwesomeIcons.calendar :
                          val == 'Rising' ? FontAwesomeIcons.arrowUp :
                          val == 'Controversial' ? FontAwesomeIcons.angry :
                          Icons.cloud_circle
                        ),
                      ),
                      Text(val)
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newVal) {
                setState(() {
                  this.sortMethod = newVal;
                  this.getSubmissions();
                });
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return this.getSubmissions();
          },
          child: SubmissionsWidget(
            submissions: this.userContentList.cast<Submission>(),
          ),
        ),      
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: CircularProgressIndicator(),
      );
    }
  }
}
