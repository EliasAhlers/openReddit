
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
  List<UserContent> _userContentList = [];
  List<Rule> _rules;
  Stream<UserContent> _userConent;
  String _sortMethod = 'Hot';
  StreamSubscription<UserContent> _newUserConentsubscription;
  bool _ready = false;
  Subreddit _subreddit;

  @override
  void initState() {
    this.populate();
    super.initState();
  }

  void populate() async {
    if(widget.futureSubreddit != null) {
      _subreddit = await widget.futureSubreddit;
      await this.getSubmissions();
      setState(() {
        _ready = true;
      });
    } else {
      _subreddit = widget.subreddit;
      await this.getSubmissions();
      setState(() {
        _ready = true;
      });
    }
    this.getRules();
  }

  void getRules() async {
    List<Rule> rules = await _subreddit.rules();
    setState(() {
      this._rules = rules;
    });
  }

  Future<void> getSubmissions() async {
    Completer completer = new Completer();

    if(this._newUserConentsubscription != null) {
      this._newUserConentsubscription.cancel();
    }
    setState(() {
      this._userContentList = [];
      this._ready = false;
    });
    switch (this._sortMethod) {
      case 'Hot': this._userConent = _subreddit.hot(); break;
      case 'Top': this._userConent = _subreddit.top(); break;
      case 'New': this._userConent = _subreddit.newest(); break;
      case 'Rising': this._userConent = _subreddit.rising(); break;
      case 'Controversial': this._userConent = _subreddit.controversial(); break;
    }
    
    this._newUserConentsubscription = this._userConent.listen((content) async {
      if(!completer.isCompleted)
      completer.complete();
      if(this.mounted)
      setState(() {
        this._userContentList.add(content);
      });
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if(_ready) {
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
                          image: NetworkImage(_subreddit.iconImage.toString() ?? '')
                        )
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'r/' + _subreddit.displayName,
                        style: TextStyle(
                          fontSize: 30
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _subreddit.data['public_description'],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 5),
                ),
                Text('Subreddit rules:'),
                this._rules != null ? 
                Expanded(
                  child: ListView.separated(
                    itemCount: this._rules.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(this._rules[index].shortName),
                        subtitle: Text(this._rules[index].description),
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
          title: Text('r/' + _subreddit.displayName),
          actions: <Widget>[
            DropdownButton(
              value: this._sortMethod,
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
              onChanged: (newVal) async {
                setState(() {
                  this._sortMethod = newVal;
                });
                await this.getSubmissions();
                setState(() {
                  this._ready = true;
                });
              },
            )
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return this.getSubmissions();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SubmissionsWidget(
              submissions: this._userContentList.cast<Submission>(),
              leading: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(_subreddit.iconImage.toString() ?? '')
                      )
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'r/' + _subreddit.displayName,
                      style: TextStyle(
                        fontSize: 30
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),      
      );
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: LinearProgressIndicator(),
      );
    }
  }
}
